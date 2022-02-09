import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';

class UsedGpuWidget extends StatelessWidget {
  final UsedGpu _usedGPU;

  const UsedGpuWidget(this._usedGPU, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Image logo;
    if (_usedGPU.gpuData.vendor == 'amd') {
      logo = Image.asset(
        'assets/images/amd_logo.png',
      );
    } else {
      logo = Image.asset('assets/images/nvidia_logo.png');
    }

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        direction: Axis.horizontal,
        children: [
          Flexible(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 70,
                width: 70,
                child: ClipRRect(
                  child: logo,
                  borderRadius: BorderRadius.circular(40),
                ),
              )),
          Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Column(
                children: [
                  Text(_usedGPU.gpuData.marketingName),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text('gpu_quantity'.tr() + ' ${_usedGPU.quantity}'),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
