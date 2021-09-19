import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';

class UsedGPUWidget extends StatelessWidget {
  final UsedGpu _usedGPU;

  UsedGPUWidget(this._usedGPU);

  @override
  Widget build(BuildContext context) {
    Image logo;
    if (_usedGPU.gpuData.vendor == 'amd')
      logo = Image.asset(
        'assets/images/amd_logo.png',
      );
    else
      logo = Image.asset('assets/images/nvidia_logo.png');

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            height: 70,
            width: 70,
            child: ClipRRect(
              child: logo,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          Column(
            children: [Text(_usedGPU.gpuData.marketingName), Text('Количество видеокарт ${_usedGPU.quantity}')],
          )
        ],
      ),
    );
  }
}
