import '../../domain/repository/display.repository.dart';
import '../../presentation/main/cubit/mall_type_cubit.dart';
import '../data_source/mock/display/menu/menu.model.dart';
import '../data_source/remote/display/display.api.dart';
import '../dto/common/response_wrapper/response_wrapper.dart';
import '../mapper/common.mapper.dart';
import '../mapper/display.mapper.dart';

class DisplayRepositoryImpl implements DisplayRepository {
  final DisplayApi _displayApi;

  DisplayRepositoryImpl(this._displayApi);

  @override
  Future<ResponseWrapper<List<Menu>>> getMenusByMallType({
    required MallType mallType,
  }) async {
    final response = await _displayApi.getMenusByMallType(mallType.name);

    return response.toModel<List<Menu>>(
      response.data?.map((e) => e.toModel()).toList() ?? [],
    );
  }
}
