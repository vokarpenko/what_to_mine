#!/usr/bin/env python3
"""Bundle WhatToMine's public coin logos. No API token or API requests are used.

Optional --catalog accepts an exported /coins JSON array (id, tag, name).
Without it, refresh the identities already recorded in the source manifest.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'assets/json/coin_icons.json'
BASE = 'https://whattomine.com'
CDN = 'https://images-production.whattomine.com/'


class CoinImages(HTMLParser):
    def __init__(self):
        super().__init__()
        self.anchors = []
        self.by_id = {}
        self.logos = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a':
            match = re.search(r'/coins/(\d+)(?:-|$)', attrs.get('href', ''))
            self.anchors.append(match.group(1) if match else None)
        if tag == 'img' and attrs.get('src', '').startswith(CDN):
            source = attrs['src']
            if self.anchors and self.anchors[-1]:
                self.by_id[self.anchors[-1]] = source
            if attrs.get('alt', '').lower().endswith(' logo'):
                self.logos.append(source)

    def handle_endtag(self, tag):
        if tag == 'a' and self.anchors:
            self.anchors.pop()


def fetch(url):
    request = urllib.request.Request(url, headers={
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'image/png,image/jpeg,image/webp,image/gif,text/html;q=0.9',
    })
    with urllib.request.urlopen(request, timeout=30) as response:
        data = response.read(5 * 1024 * 1024 + 1)
    if len(data) > 5 * 1024 * 1024:
        raise ValueError('Unexpectedly large response')
    return data


def parse_page(html):
    parser = CoinImages()
    parser.feed(html.decode('utf-8'))
    return parser


def image_suffix(data):
    if data.startswith(b'\x89PNG\r\n\x1a\n'):
        return 'png'
    if data.startswith(b'\xff\xd8\xff'):
        return 'jpg'
    if data.startswith((b'GIF87a', b'GIF89a')):
        return 'gif'
    if data.startswith(b'RIFF') and data[8:12] == b'WEBP':
        return 'webp'
    if b'<svg' in data[:4096]:
        return 'svg'
    raise ValueError('Unsupported image response')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--catalog', type=Path)
    parser.add_argument('--cached-index', type=Path)
    parser.add_argument('--refresh', action='store_true', help='Re-download existing logos')
    args = parser.parse_args()
    if args.catalog:
        rows = json.loads(args.catalog.read_text())
    else:
        rows = list(json.loads(MANIFEST.read_text())['coins'].values())
    catalog = {str(row['id']): {k: row[k] for k in ('id', 'tag', 'name')} for row in rows}
    if any(not re.fullmatch(r'\d+', identity) for identity in catalog):
        raise ValueError('Coin IDs must be numeric')
    index = args.cached_index.read_bytes() if args.cached_index else fetch(BASE + '/')
    known = parse_page(index).by_id
    output = ROOT / 'assets/icons/coins'
    output.mkdir(parents=True, exist_ok=True)
    existing = json.loads(MANIFEST.read_text())['coins'] if MANIFEST.exists() else {}
    results, failures = {}, []

    def load(entry):
        identity, coin = entry
        previous = existing.get(identity)
        if not args.refresh and previous and (ROOT / previous['asset']).is_file():
            return identity, previous
        source = known.get(identity)
        if source is None:
            page = parse_page(fetch(BASE + '/coins/' + identity))
            source = page.by_id.get(identity) or (page.logos[0] if page.logos else None)
        if source is None:
            raise ValueError('No public logo found')
        data = fetch(source)
        filename = identity + '.' + image_suffix(data)
        path = output / filename
        path.write_bytes(data)
        return identity, {**coin, 'asset': str(path.relative_to(ROOT)), 'source': source}

    with ThreadPoolExecutor(max_workers=4) as pool:
        pending = {pool.submit(load, entry): entry[0] for entry in catalog.items()}
        for future in as_completed(pending):
            identity = pending[future]
            try:
                identity, row = future.result()
                results[identity] = row
            except Exception as error:
                failures.append(identity)
                print('Logo unavailable for coin', identity, type(error).__name__, flush=True)
            if (len(results) + len(failures)) % 20 == 0:
                print('Processed', len(results) + len(failures), '/', len(catalog), flush=True)
    results = dict(sorted(results.items(), key=lambda pair: int(pair[0])))
    MANIFEST.write_text(json.dumps({
        'provider': BASE,
        'notes': 'Original coin logos from public WhatToMine pages; no API token required.',
        'coins': results,
    }, ensure_ascii=False, indent=2) + '\n')
    dart = '// Generated by tools/sync_coin_icons.py. Do not edit.\n'
    dart += 'const coinIconAssets = <String, String>{\n'
    for identity, row in results.items():
        dart += f"  '{identity}': '{row['asset']}',\n"
    dart += '};\n'
    (ROOT / 'lib/src/ui/widgets/coin_icon_assets.dart').write_text(dart)
    print('Bundled logos:', len(results), '/', len(catalog), flush=True)
    print('Image bytes:', sum((ROOT / row['asset']).stat().st_size for row in results.values()), flush=True)
    if failures:
        print('Missing coin IDs:', ', '.join(failures), flush=True)


if __name__ == '__main__':
    main()
