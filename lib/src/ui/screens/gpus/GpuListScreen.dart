import 'package:flutter/material.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/ui/contstants.dart';
import 'package:what_to_mine/src/ui/widgets/UsedGPUWidget.dart';

import 'GpuListViewModel.dart';

class GPUListScreen extends StatefulWidget {
  final GPUListViewModel _viewModel = GPUListViewModel();

  @override
  State<StatefulWidget> createState() {
    return GPUListScreenState(_viewModel);
  }
}

class GPUListScreenState extends State<GPUListScreen> {
  final GPUListViewModel _viewModel;
  //List<GPU>? _gpus;

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    //_viewModel.gpus.listen((gpus) => _gpus = gpus);
    _viewModel.addGPU.listen((_) => _showAddGPUDialog());
  }

  GPUListScreenState(this._viewModel);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ваши видеокарты"),
      ),
      body: Center(
        child: StreamBuilder<List<UsedGpu>>(
          stream: _viewModel.usedGpus,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.isNotEmpty)
                return ListView.builder(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return UsedGPUWidget(snapshot.data![index]);
                  },
                );
              else
                return (Text("Список видеокарт пуст, добавьте ваши первые видеокарты"));
            } else
              return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "gpuAdd",
        onPressed: _onClickAddGPU,
        child: Icon(Icons.add),
      ),
    );
  }

  void _onClickAddGPU() {
    _viewModel.onClickAddGPU();
  }

  void _showAddGPUDialog() {
    // Switch
    bool switchValueIsNvidia = true;
    String vendor = "Nvidia";
    // DropdownButton
    List<Gpu> _gpus = _viewModel.onFilterGPUListByVendor(vendor);
    Gpu selectedGpu = _gpus.first;

    new Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Добаление видеокарты"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(vendor, textAlign: TextAlign.end),
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                            flex: 1,
                            child: Switch(
                              activeColor: Colors.green,
                              inactiveTrackColor: AppColors.lightRed,
                              inactiveThumbColor: Colors.red,
                              value: switchValueIsNvidia,
                              onChanged: (bool isNvidia) {
                                setState(() {
                                  switchValueIsNvidia = isNvidia;
                                  isNvidia ? vendor = "Nvidia" : vendor = "AMD";
                                  _gpus = _viewModel.onFilterGPUListByVendor(vendor);
                                  selectedGpu = _gpus.first;
                                });
                              },
                            ))
                      ],
                    ),
                    DropdownButton<Gpu>(
                      value: selectedGpu,
                      isExpanded: true,
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: switchValueIsNvidia ? Colors.green : Colors.red),
                      underline: Container(
                        height: 1,
                        color: switchValueIsNvidia ? Colors.green : Colors.red /*Theme.of(context).accentColor*/,
                      ),
                      onChanged: (Gpu? newValue) {
                        setState(() {
                          selectedGpu = newValue!;
                        });
                      },
                      items: _gpus.map<DropdownMenuItem<Gpu>>((Gpu value) {
                        return DropdownMenuItem<Gpu>(
                          value: value,
                          child: Text(value.marketingName),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text("ОТМЕНА")),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _viewModel.onAddGPU(selectedGpu, 1);
                      },
                      child: Text("OK"))
                ],
              );
            },
          );
        },
      );
    });
  }
}
