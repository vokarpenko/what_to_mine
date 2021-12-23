import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/gpu/Gpu.dart';
import 'package:what_to_mine/src/domain/gpu/UsedGpu.dart';
import 'package:what_to_mine/src/ui/contstants.dart';
import 'package:what_to_mine/src/ui/widgets/UsedGPUWidget.dart';

import 'GpuListViewModel.dart';

class GpuListScreen extends StatefulWidget {
  final GpuListViewModel _viewModel = GpuListViewModel();

  @override
  State<StatefulWidget> createState() {
    return GpuListScreenState(_viewModel);
  }
}

class GpuListScreenState extends State<GpuListScreen> {
  final GpuListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.onViewInitState();
    _viewModel.addGPU.listen((_) => _showAddGPUDialog());
  }

  GpuListScreenState(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gpus_appbar_title'.tr()),
      ),
      body: Center(
        child: StreamBuilder<List<UsedGpu>>(
          stream: _viewModel.usedGpus,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<UsedGpu> items = [];
              items = snapshot.data!;
              if (snapshot.data!.isNotEmpty) {
                int itemsCount = snapshot.data!.length;
                if (itemsCount > 0)
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    itemCount: itemsCount,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          _viewModel.deleteUsedGpu(items[index].gpuData.id);
                          setState(() {
                            items.removeAt(index);
                            itemsCount = items.length;
                          });
                        },
                        key: Key(item.gpuData.id),
                        child: UsedGPUWidget(items[index]),
                      );
                    },
                  );
                else
                  return _buildEmptyGpuListLabel();
              } else
                return _buildEmptyGpuListLabel();
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
      TextEditingController controller = TextEditingController(text: "1");
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('adding_gpus'.tr()),
                content: SingleChildScrollView(
                  child: Column(
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
                                activeTrackColor: AppColors.lightGreen,
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
                      TextField(
                          decoration: new InputDecoration(hintText: 'quantity'.tr()),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          controller: controller)
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text('cancel'.tr())),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _viewModel.onAddGPU(selectedGpu, int.parse(controller.value.text));
                      },
                      child: Text('ok'.tr()))
                ],
              );
            },
          );
        },
      );
    });
  }

  Text _buildEmptyGpuListLabel() {
    return Text(
      'empty_gpus_message'.tr(),
      textAlign: TextAlign.center,
    );
  }
}
