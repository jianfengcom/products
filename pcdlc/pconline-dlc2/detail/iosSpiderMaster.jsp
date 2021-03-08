<%@ page import="org.gelivable.web.EnvUtils" %>
<%@ page import="org.gelivable.web.Env" %><%@ page import="cn.pconline.pcdlc.util.SpiderUtil"%><%@ page import="cn.pconline.pcdlc.entity.ClientMasterSpider"%><%@ page import="cn.pconline.pcdlc.entity.ClientMaster2"%><%@ page import="cn.pconline.pcdlc.util.JspUtil"%><%@ page import="java.net.URLDecoder"%>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    Env env = EnvUtils.getEnv();
    String name = URLDecoder.decode(env.param("name",""), "UTF-8"); // 名称
	String url = URLDecoder.decode(env.param("url", ""), "UTF-8"); // url
	System.out.println("name=" + name + ", url=" + url);

    try{
			ClientMasterSpider clientMasterSpider = SpiderUtil.spiderMaster(url ,null,"developer/add_ios.jsp");
			if(clientMasterSpider == null){
				throw new RuntimeException("抓取苹果商店失败，检查链接");
			}
			//与苹果的名称一致
			if(!clientMasterSpider.getName(  ).equals( name )){
			    // ClientMaster2.APPLE_NAME_NOT_SAME_AS_ITUNES
			    System.out.println("苹果名称与官网不一致");
			}
			System.out.println("成功啦!!!");
		}catch(Exception ex){
			ex.printStackTrace(  );
			// ClientMaster2.SPIDER_APPLE_MESSAGE_ERROR
			System.out.println("同步苹果官网异常");
			return;
		}


    out.print("掂");
%>
