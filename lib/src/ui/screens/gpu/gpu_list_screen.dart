import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what_to_mine/src/domain/gpu/gpu.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import 'package:what_to_mine/src/ui/widgets/used_gpu_widget.dart';
import 'package:what_to_mine/src/utils/ui_utils.dart';

import 'gpu_list_view_model.dart';

class GpuListScreen extends StatefulWidget {
  const GpuListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return GpuListScreenState();
  }
}

class GpuListScreenState extends State<GpuListScreen>
    with TickerProviderStateMixin {
  final GpuListViewModel _viewModel = GpuListViewModel();
  StreamSubscription? _subscriptionAddGpu, _subscriptionError;
  late AnimationController _hideFabAnimation;

  GpuListScreenState();

  @override
  void initState() {
    super.initState();
    _hideFabAnimation = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _hideFabAnimation.forward();
    _viewModel.onViewInitState();
    _subscriptionAddGpu = _viewModel.addGpu.listen((_) => _showAddGPUDialog());
    _subscriptionError = _viewModel.errorMessage.listen((error) {
      if (!mounted) return;
      UIUtils.showAlertDialog(context, 'error'.tr(), error, 'ok'.tr());
    });
  }

  @override
  void dispose() {
    super.dispose();
    this
      .._viewModel.onViewDispose()
      .._hideFabAnimation.dispose()
      .._subscriptionAddGpu?.cancel()
      .._subscriptionError?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('gpus_appbar_title'.tr())),
      body: Center(
        child: StreamBuilder<List<UsedGpu>>(
          stream: _viewModel.usedGpus,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<UsedGpu> items = [];
              items = snapshot.data!;
              if (snapshot.data!.isNotEmpty) {
                int itemsCount = snapshot.data!.length;
                if (itemsCount > 0) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
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
                        child: UsedGpuWidget(items[index]),
                      );
                    },
                  );
                } else {
                  return _buildEmptyGpuListWidget();
                }
              } else {
                return _buildEmptyGpuListWidget();
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _hideFabAnimation,
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          heroTag: "gpuAdd",
          onPressed: _onClickAddGPU,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _onClickAddGPU() {
    //_hideFabAnimation.reverse();
    _viewModel.onClickAddGPU();
  }

  void _showAddGPUDialog() {
    final vendors = _viewModel.vendors;
    if (vendors.isEmpty) return;
    String vendor = vendors.first;
    List<Gpu> gpus = _viewModel.onFilterGPUListByVendor(vendor);
    Gpu selectedGpu = gpus.first;

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      TextEditingController controller = TextEditingController(text: '1');
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
                      DropdownButton<String>(
                        value: vendor,
                        isExpanded: true,
                        items: vendors
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            vendor = value;
                            gpus = _viewModel.onFilterGPUListByVendor(vendor);
                            selectedGpu = gpus.first;
                          });
                        },
                      ),
                      DropdownButton<Gpu>(
                        value: selectedGpu,
                        isExpanded: true,
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (Gpu? newValue) {
                          setState(() {
                            selectedGpu = newValue!;
                          });
                        },
                        items: gpus.map<DropdownMenuItem<Gpu>>((Gpu value) {
                          return DropdownMenuItem<Gpu>(
                            value: value,
                            child: Text(value.marketingName),
                          );
                        }).toList(),
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: 'quantity'.tr()),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^([1-9]){1}([0-9]{1,2})?'),
                          ),
                        ],
                        keyboardType: TextInputType.number,
                        controller: controller,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      //_hideFabAnimation.forward();
                      Navigator.pop(context);
                    },
                    child: Text('cancel'.tr()),
                  ),
                  TextButton(
                    onPressed: () async {
                      //_hideFabAnimation.forward();
                      Navigator.pop(context);
                      final quantity = int.tryParse(controller.text);
                      if (quantity != null && quantity > 0) {
                        _viewModel.onAddGPU(selectedGpu, quantity);
                      }
                    },
                    child: Text('ok'.tr()),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  Widget _buildEmptyGpuListWidget() {
    Brightness brightness = Theme.of(context).brightness;
    String imagePath = brightness == Brightness.light
        ? 'assets/images/not_gpus.png'
        : 'assets/images/not_gpus_bw.png';
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          Container(
            padding: const EdgeInsets.only(top: 30, left: 5, right: 5),
            child: Text(
              'empty_gpus_message'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
