# 买什么都省SDK接入指南
**本SDK作用是在买什么都省提供的H5页面上显示穿山甲的广告** 

# 集成
**本SDK依赖穿山甲SDK提供的功能，请先根据穿山甲提供的文档进行穿山甲SDK的集成**    
*说明：本SDK目前只支持真机调试，iOS10及以上版本*    
**步骤 1：工程设置**    
*将demo中的‘msmdsadsdk.framework’和‘msmdsresource.bundle’拖入工程中*   
 
# 使用    
```
// 导入SDK中的提供viewController
#import <msmdsadsdk/MsmWebViewController.h>

/**
 参数说明：
 url：这是买什么都省提供的H5链接
 showToolbar：是否显示页面头部的toolbar，默认不显示
 bannerCodeId：这是由接入方自行申请的banner广告位ID
 nativeCodeId：这是由接入方自行申请的信息流广告位ID
 rewardVideoCodeId：这是由接入方自行申请的激励视频广告位ID
 */

MsmWebViewController *msmWebController = [MsmWebViewController new];
msmWebController.url = @"https://wxapp.msmds.cn/h5/react_web/sign";
msmWebController.showToolbar = YES;
msmWebController.bannerCodeId = @"945413865";
msmWebController.nativeCodeId = @"945198258";
msmWebController.rewardVideoCodeId = @"945198260";
    
[self.navigationController pushViewController:msmWebController animated:YES];
```

