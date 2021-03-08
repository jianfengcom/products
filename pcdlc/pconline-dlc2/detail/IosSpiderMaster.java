import or.apache.http.client.HttpClientUtil;
import or.apache.http.client.Vo;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IosSpiderMaster {

    public static void main(String[] args) {
        spider();
    }

    public static void spider() {
        List<Vo> list = new ArrayList<>();
        Map<String, Object> params = new HashMap<>();
        String name = "口袋蜜蜂";
        String urlP = "https://apps.apple.com/cn/app/id1268533784";
        try {
            // 编码
            urlP = URLEncoder.encode(urlP, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        params.put("name", name);
        params.put("url", urlP);

        String url = "http://local.pconline.com.cn:9991/intf/iosSpiderMaster.jsp";
        String result = HttpClientUtil.post(url, params, "UTF-8");
        System.out.println(result);
    }
}
