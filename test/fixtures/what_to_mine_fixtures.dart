const wtmAlgorithms = [
  {'name': 'KawPow', 'param_name': 'kp'},
  {'name': 'Etchash', 'param_name': 'eth4g'},
];

const wtmCoins = [
  {
    'id': 234,
    'tag': 'RVN',
    'name': 'Ravencoin',
    'algorithm': 'KawPow',
    'algo_param_name': 'kp',
    'lagging': false,
    'testing': false,
    'default_fee': 1.0,
    'nethash': '1000000000000',
    'exchanges': [
      {'name': 'A', 'price': '0.00000020', 'volume': '1.5'},
      {'name': 'B', 'price': '0.00000010', 'volume': '10.5'},
    ],
  },
  {
    'id': 162,
    'tag': 'ETC',
    'name': 'Ethereum Classic',
    'algorithm': 'Etchash',
    'algo_param_name': 'eth4g',
    'lagging': false,
    'testing': false,
    'nethash': 200000000000000,
    'exchanges': [
      {'name': 'A', 'price': 0.0001, 'volume': 25.0},
    ],
  },
];

const wtmGpus = [
  {
    'id': 1,
    'name': 'GeForce RTX 4090',
    'algorithms': [
      {'name': 'KawPow', 'hashrate': '62000000', 'power': 370},
      {'name': 'Etchash', 'hashrate': 125000000, 'power': '350'},
    ],
  },
  {
    'id': 2,
    'name': 'Radeon RX 7900 XTX',
    'algorithms': [
      {'name': 'KawPow', 'hashrate': 60000000, 'power': 300},
      {'name': 'Etchash', 'hashrate': 100000000, 'power': 290},
    ],
  },
];

const wtmCalculation = [
  {
    'id': 234,
    'tag': 'RVN',
    'name': 'Ravencoin',
    'estimated_rewards': '1.5',
    'estimated_rewards24': '1.0',
    'btc_revenue': '0.0000015',
    'revenue': '0.15',
    'revenue24': '0.10',
    'profit': '-0.09',
    'profit24': '-0.14',
  },
];
