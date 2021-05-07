<%@page import="cn.com.pc.util.StringUtils"%>
<%@page import="com.alibaba.fastjson.*"%>
<%@page import="cn.com.pc.cosme.index.*"%>
<%@page import="cn.com.pc.cosme.index.dlucene.*"%>
<%@page contentType="text/html; charset=GBK" pageEncoding="GBK" session="false"%>
<%@page import="org.apache.solr.client.solrj.response.QueryResponse"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><fmt:setLocale value="zh"/>
<%@taglib prefix="memcached" uri="/WEB-INF/memcached.tld"%>
<%@include file="/common/common.jspf"%>
<%
    long csListId = env.paramLong("csListId", 0);
    long bigSortId = env.paramLong("bid", 0);
    long smallSortId = env.paramLong("sid", 0);
    SortService sortService = SortService.instance();
    SmallSort smallSort = null;
    BigSort bigSort = null;
    if(smallSortId > 0){
    	smallSort = sortService.findSmallSort(smallSortId);       
        if(smallSort == null || (smallSort != null && smallSort.getStatus() < 0)){
        	response.sendError( 404 );
    		return;
        }
        bigSort = smallSort.getBigSort();
        pageContext.setAttribute("smallSort",smallSort);
        pageContext.setAttribute("bigSort",bigSort);
    }
    if(smallSortId <=0 && bigSortId > 0){
    	bigSort = sortService.findBigSort(bigSortId);     
        if(bigSort == null || (bigSort != null && bigSort.getStatus() < 0)){
        	response.sendError( 404 );
    		return;
        }
        pageContext.setAttribute("bigSort",bigSort);
    }
    CSList csList = null;
    if(csListId > 0){
    	csList = CSListService.instance().find(csListId);    
        if(csList == null || (csList != null && csList.getStatus() <= 0)){
        	response.sendError( 404 );
    		return;
        }
        pageContext.setAttribute("csList",csList);
    }
    
    request.setAttribute( "bigSortId", bigSortId );
    request.setAttribute( "smallSortId", smallSortId );
    request.setAttribute( "csListId", csListId );
    String titleName = "";
    String mobileUrl = "bi" + bigSortId + "_sm" + smallSortId + ".html";
    CommonTDKService commonTDKService = CommonTDKService.instance();
    CommonTDK commonTDK = null;
    boolean isTopRank = false;  // true 是一周至尊
    if (smallSort != null) {
    	titleName = smallSort.getName();
    } else if (bigSort != null){
    	titleName = bigSort.getName();
    } else if (csList != null){
    	titleName = csList.getName();
    	mobileUrl = "t" + csListId + ".html";
    } else {
    	titleName = "一周至尊";
    	isTopRank = true; //表示一周至尊榜
    	commonTDK = commonTDKService.findByType(1);   //type==1 : 表示一周至尊榜
    }
    
    //---------------------TDK处理-------------------------
    StringBuffer titleComplate = new StringBuffer();
    if (csList == null && commonTDK == null || (
    		(commonTDK != null && StringUtils.isEmpty(commonTDK.getSeoTitle()) && isTopRank)  // 一周至尊榜 并且title为空
    			|| (csList != null && StringUtils.isEmpty(csList.getSeoTitle()) && !isTopRank))) {
    	titleComplate.append(titleName);
        if (smallSort != null || bigSort != null) {
        	titleComplate.append("什么" + titleName + "好用");
        }
    } else {
    	if (isTopRank) {
    		titleComplate.append(commonTDK.getSeoTitle());
    	} else {
    		titleComplate.append(csList.getSeoTitle());
    	}
    }
    
    
    String keywords = "化妆品心得,化妆品心得分享,化妆品使用心得分享";
    if(csList!=null && !isTopRank && !StringUtils.isEmpty(csList.getSeoKeyword())){
    	keywords = csList.getSeoKeyword();
    }else if(commonTDK!=null && isTopRank && !StringUtils.isEmpty(commonTDK.getSeoKeyword())){
    	keywords =commonTDK.getSeoKeyword();
    }
    String description = "太平洋时尚网点评库是姐妹们化妆品使用心得的分享驿站。你可以浏览到最齐全最全面的化妆品，在这里也为每个人提供了良好的交流平台，让每个人都可更了解适合自己的产品并与和每个热爱化妆品的姐妹们分享美容心得。";
    if(csList!=null && !isTopRank && !StringUtils.isEmpty(csList.getSeoDescription())){
    	description = csList.getSeoDescription();
    }else if(commonTDK!=null && isTopRank && !StringUtils.isEmpty(commonTDK.getSeoDescription())){
    	description = commonTDK.getSeoDescription();
    }
    //---------------------TDK处理-------------------------
    
    request.setAttribute( "title", titleComplate.toString());
    request.setAttribute( "keywords", keywords);
    request.setAttribute( "description", description);
    request.setAttribute( "csList", csList);
    request.setAttribute( "mobileUrl", mobileUrl);
    request.setAttribute( "titleName", titleName);
    request.setAttribute("column", 5);
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="gb2312" /> 
	<title>${title}_太平洋时尚网化妆品点评库</title>
	<meta name="keywords" content="${keywords}" />
	<meta name="description" content="${description}" />
	<meta name="Author" content="minzhixiong_gz liushuzhen_gz" />
	<!-- 设备跳转模块 S -->
	<script>
	<%@ include file="/global_ssi/pclady/jump/index.html"%>
        deviceJump.init({
          "main": "//cosme.pclady.com.cn/products_hot/${mobileUrl}",//这里需要开发动态写入pc版连接,如没有可为空
          "ipad": "",//这里需要开发动态写入ipad版连接,如没有可为空
          "wap": "//g.pclady.com.cn/cosme/products_hot/${mobileUrl}",//这里需要开发动态写入简版连接,如没有可为空
          "wap_3g": "//g.pclady.com.cn/cosme/products_hot/${mobileUrl}"//这里需要开发动态写入炫版连接,如没有可为空
        });
    </script>
    <!-- 设备跳转模块 E -->
	<!-- 百度统计代码 S -->
    <script>
		var _hmt = _hmt || [];
		(function() {
		  var hm = document.createElement("script");
		  hm.src = "https://hm.baidu.com/hm.js?c63c409073597b6c03e043dd8a231d0f";
		  var s = document.getElementsByTagName("script")[0]; 
		  s.parentNode.insertBefore(hm, s);
		})();
	</script>
	<!-- 百度统计代码 E -->
	<meta name="mobile-agent" content="format=html5;url=//g.pclady.com.cn/cosme/products_hot/${mobileUrl}">
	<meta content="always" name="referrer"/>
	<link rel="stylesheet" type="text/css" href="//js.3conline.com/pclady/2017/cosme/bdlist.css">
</head>
<body>
 
	<script>if(!window._addIvyID) document.write("<scr"+"ipt src='//www.pconline.com.cn/_hux_/lady/default/index.js'><\/scr"+"ipt>")
    </script>
    <!-- 栏目计数器 -->
    <span class="spanclass">
      <script>
	  window._common_counter_code_='channel=5467';
	  window._common_counter_uuid_='';
	  <%@include file="/global_ssi/pclady/count/index.html" %>
      </script>
    </span>
 
    
    <!--头部-->
    <div class="navibar-in-wrap">
    	<%@include file="/global_ssi/pclady/navibar/index.html" %>
    </div>
        <div class="doc" id="Jwrapper">
        <%@include file="/common/header3_forSlide.jspf"%>
        <div class="screen-outer" id="J-Select">
            <div class="main">
                <div class="guide">
                    <a href="${t:replaceHttpWeb(ROOT)}/" target="_blank">化妆品库首页</a>&gt; <a href="${t:replaceHttpWeb(ROOT)}/products_hot.html" target="_blank">排行榜</a>&gt; <span> ${titleName}榜</span>
                </div>
                <memcached:cache key="product_sort_hot_menu_csListId${csListId}_bigSortId${bigSortId}_smallSortId${smallSortId}" time="6452" refresh="${param.refresh}">
                <%
			       List<BigSort> bigSorts = SortService.instance().getBigSorts();
			       BigSort temp1=bigSorts.get( 5 );
			       BigSort temp2=bigSorts.get( 8 );
			       bigSorts.set( 8, temp1 );
			       bigSorts.set( 5, temp2 );
			       request.setAttribute("bigSorts", bigSorts);
			       List<CSList> csLists = CSListService.instance().getCSLists(1, 1, 1, 10, 0);	
			       request.setAttribute("csLists", csLists);
		        %>
                <div class="col-left">                  
                 <div class="pro-side">               
		            <div class="sort-menu">                      
                        <a class="hd J_toggleMenu" href="${t:replaceHttpWeb(ROOT)}/products_hot.html" data-class="one">全部榜单</a>
                    </div>
                    <div class="sort-menu${bigSortId == 0 && smallSortId == 0 && csListId == 0 ? ' menu-open-cur' : ''}">                      
                        <a class="hd J_toggleMenu" href="${t:replaceHttpWeb(ROOT)}/products_hot/bi0_sm0.html" data-class="one">一周至尊榜</a>
                    </div>
                    <div class="sort-menu${csListId > 0 ? ' menu-open-cur one-menu-open' : ''}">                                           
                       <a class="hd J_toggleMenu" data-class="one">特色口碑榜<span class="icon-arrow"></span></a>
						<div class="sort-menu-pannel">
							<div class="second-menu">
								<ul class="bd">
		                           <c:forEach var="cs" items="${csLists}" varStatus="index">
                                        <li${cs.id == csListId ? ' class="active"' : ''}><a href="${t:replaceHttpWeb(ROOT)}/products_hot/t${cs.id}.html">${cs.name}</a></li>
                                   </c:forEach>  
		                        </ul>
							</div>
							
                        </div>	
                    </div>            
                    <div class="sort-menu${bigSortId > 0 || smallSortId > 0 ? ' menu-open-cur one-menu-open' : ''}">
                       <a class="hd J_toggleMenu" data-class="one">分类排行榜<span class="icon-arrow"></span></a>
                       <div class="sort-menu-pannel">
                         <c:forEach var="bi" items="${bigSorts}" varStatus="v">
							<div class="side-menu${bigSorts.get(v.index).id == bigSortId ? ' s-menu-open' : ''}">
		                        <a class="s-hd J_toggleMenu" data-class="s">${bi.name}<span class="icon-arrow"></span></a>
		                        <ul class="bd">
		                         <li${bigSortId == bi.id && smallSortId == 0 ? ' class="active"' : ''}><a href="${t:replaceHttpWeb(ROOT)}/products_hot/bi${bi.id}_sm0.html">${bi.name}总榜</a></li>
		                          <c:forEach var="sm" items="${bi.avaliableSmallSorts}" varStatus="index">
                                      <c:if test="${sm.id != 141 && sm.id != 269 && sm.id != 279 && sm.id != 14 && sm.id != 97 && sm.id != 199 && sm.id != 349 && sm.id != 399}">
                                        <li${smallSortId == sm.id ? ' class="active"' : ''}><a href="${t:replaceHttpWeb(ROOT)}/products_hot/bi${bi.id}_sm${sm.id}.html">${sm.name}</a></li>
                                      </c:if>
                                  </c:forEach>
                                </ul>
		                    </div>
		                   </c:forEach> 
		                </div>                    
                    </div>
                    <div class="sort-menu">
                       <a class="hd J_toggleMenu" data-class="one">品牌排行榜<span class="icon-arrow"></span></a>
                       <div class="sort-menu-pannel">
                            <c:forEach var="bi" items="${bigSorts}" varStatus="v">
                            <div class="side-menu">
                                <a class="s-hd J_toggleMenu" data-class="s">${bi.name}<span class="icon-arrow"></span></a>
                                <ul class="bd">
                                  <li><a href="${t:replaceHttpWeb(ROOT)}/products_hot/bi${bi.id}_sm0_brand.html">${bi.name}总榜</a></li>
                                  <c:forEach var="sm" items="${bi.avaliableSmallSorts}" varStatus="index">
                                      <c:if test="${sm.id != 141 && sm.id != 349 && sm.id != 13}">
                                        <li><a href="${t:replaceHttpWeb(ROOT)}/products_hot/bi${bi.id}_sm${sm.id}_brand.html">${sm.name}</a></li>
                                      </c:if>
                                  </c:forEach>
                                </ul>
                            </div>
                            </c:forEach> 
                        </div>                    
                    </div>
                </div>                
                </div>
                </memcached:cache>
                <div class="col-right">
                <memcached:cache key="product_sort_hot_pro_csListId${csListId}_bigSortId${bigSortId}_smallSortId${smallSortId}" time="6452" refresh="${param.refresh}">  
                <%
                  List<Product> products = new ArrayList<Product>();
				  if(smallSort!=null){//分类排行榜
					  products = ProductService.instance().getProductsBySm((int)smallSort.getId());		      
					}else if(bigSort != null){//分类排行榜
						products = ProductService.instance(  ).getProByBigSort( bigSortId );					  
					}else if(csList != null){//特色榜单
						List<CSListProduct> csListProducts = csList.getCsListProducts();	
						if(csListProducts != null && csListProducts.size() > 0){
							for(CSListProduct cs : csListProducts){
								products.add(cs.getProduct());
							}
							 request.setAttribute("reason", csListProducts.get(0).getReason());
						}
					}else{//一周至尊榜
						List<WeeklyExtremeProduct> weeExProducts = WeeklyExtremeProductService.instance().listTop(9);
						if(weeExProducts != null && weeExProducts.size() > 0){
					       for(WeeklyExtremeProduct weeExPro:weeExProducts){
						       Product product = ProductService.instance().find(weeExPro.getProductId());
						       if(product!=null && product.getStatus()>0){
						    	   products.add(product);
					           }
				           }
					       request.setAttribute("reason", weeExProducts.get(0).getReason());
						}					      
					}			       
			       request.setAttribute("products", products);//一周至尊榜
			       
			     	// 获取products中最大更新时间
			     	if (products != null && products.size() > 0) {
				     	Date upDate = products.get(0).getUpdateAt();
				       	for (int i = 0; i < products.size(); ++i) {
				       		Date date = products.get(i).getUpdateAt();
                            if (date == null) {
                                continue;
                            }
				       		if (upDate == null || date.getTime() > upDate.getTime()) {
				       			upDate = date;
				       		}
				       	}
                        if (upDate != null) {
                            request.setAttribute("upDate", T.format(upDate, "yyyy-MM-dd'T'HH:mm:ss"));
                        }
			     	}
					%>
					<!-- 熊掌号改造代码  -->		
					<script type="application/ld+json">	
       		 		{				
           		 		"@context": "https://ziyuan.baidu.com/contexts/cambrian.jsonld",
           		 		"@id": "${t:replaceHttpToHttps(ROOT)}/products_hot/<c:if test="${csList != null}">t${csListId}</c:if><c:if test="${csList == null}">bi${bigSortId}_sm${smallSortId}</c:if>.html",				
           		 		"appid": "1537816883071662",
           		 		"title": "${titleName}排行榜_<c:if test="${smallSort != null || bigSort != null}">什么${titleName}好用</c:if><c:if test="${smallSort == null && bigSort == null}">${titleName}榜</c:if>_太平洋时尚网化妆品点评库",							
						"images": [	
               		 		"https://img.pclady.com.cn/images/upload/upc/tx/lady_cosme/1710/31/c0/65171398_1509417144247_400x400.png",
					 		"https://img.pclady.com.cn/images/upload/upc/tx/lady_cosme/1803/29/c0/80012827_1522291931766_400x400.jpg",
					 		"https://img.pclady.com.cn/images/upload/upc/tx/lady_cosme/1511/22/c1/15567142_1448203341758_400x400.png"	
            	 		], 				
            			"upDate": "${upDate}"			
        			}				
   					</script>				
                    <div class="listSel" id="Jsnav">                      
                        <div class="dSel">
                           <c:if test="${(smallSort != null || bigSort != null) && csListId <= 0}">
                              <h3>${titleName}排行榜</h3> 
                           </c:if>
                            <c:if test="${smallSort == null && bigSort == null && csListId <= 0}">
                              <h3>${titleName}榜</h3> 
                           </c:if>
                           <c:if test="${csListId > 0}">
                           		<h3>${csList.name}</h3>
                           </c:if>
                        </div>
                        <!-- 商品列表页 -->
                        <div class="dList">
                         <c:if test="${!empty products}">
                            <ul>
                                  <c:forEach var="p" items="${products}" varStatus="index" begin="0" end="9">
                                  <c:set var="oneComment" value="${p.getComments(1)}" />
                                    <c:if test = "${index.count == 5}">
                                        <li>
                                            <i class="sum sum5"></i>
                                            <i class="iBox" id="input110427">
                                                <a href="javascript:;" class="addId" onclick="common.addToBox(this);" value="110427,灵芝生机焕活肌底精华液,//img.pclady.com.cn/images/upload/upc/tx/lady_cosme/1701/12/c0/35346833_1484211107336_400x400.jpg,//cosme.pclady.com.cn/product/110427.html"><em>加入对比</em>
                                                </a>
                                                <a href="javascript:void(0)" class="deleteon" style="display: none" onclick="common.deleteCompare(110427,this);common.updateCompareCookie(110427);common.updatePro();">取消对比</a>
                                            </i>
                                            <i class="iPic">
                                                <!-- 是否正在试用 -->

                                                <a href="//cosme.pclady.com.cn/product/110427.html" target="_blank">
                                                    <img src="//img.pclady.com.cn/images/upload/upc/tx/lady_cosme/1701/12/c0/35346833_1484211107336_400x400.jpg" title="羽西 灵芝生机焕活肌底精华液" width="200" height="200"> </a> </i>
                                            <i class="iInfo">
                                                <span class="sTit">
                                                    <a href="//cosme.pclady.com.cn/product/110427.html" title="灵芝生机焕活肌底精华液" target="_blank">羽西 灵芝生机焕活肌底精华液</a>
                                                </span>
                                                <span class="sKey">
                                                <a href="//cosme.pclady.com.cn/yuesai.html" target="_blank">羽西<i></i>
											    </a>
											    <a href="//cosme.pclady.com.cn/products_list/br0_bs0_bi1_sm0_ef0_pb0_pe0_or0.html" target="_blank">护肤<i></i>
											    </a>
											    <a href="//cosme.pclady.com.cn/products_list/br0_bs0_bi0_sm95_ef0_pb0_pe0_or0.html" target="_blank">肌底液<i></i>
											    </a>

											<a href="//cosme.pclady.com.cn/products_list/br0_bs0_bi0_sm0_ef3_pb0_pe0_or0.html" target="_blank">补水<i></i>
											</a>

                                            </span>
                                                <span class="sPay">参考价格：<em>￥295</em>  产品规格：30ml</span>
                                                <span class="sDP">



                                             <p>
                                             <span>Yuki：</span>
                                             <a href="//cosme.pclady.com.cn/product_comment_reply/5551933.html" target="_blank">继续来写羽西灵芝守护盒的小宝贝吧，这次要出场的是羽西灵芝生机焕活肌底精华液~ 羽西灵芝生机焕...</a>
                                             </p>

                                             <p>
                                             <span>猫太郎：</span>
                                             <a href="//cosme.pclady.com.cn/product_comment_reply/5928447.html" target="_blank">618真是个心动的日子，总是会刷着刷着就把东西带回家，除了零食最爱买的就是护肤品了。&nbsp;囤...</a>
                                             </p>



                                             </span>
                                            </i>
                                            <i class="iFix"> <span class="sCon"></span>
                                                <span class="sNub">评分：<em>8.8</em></span>
                                                <span class="module_cmt_scoreStar"><span class="score_star" data-score="8.8" data-load="loaded"><em></em><em></em><em></em><em></em><em style="width: 6px;"></em></span></span>
                                                <span class="sNub">点评：<em class="fs14">145</em>条</span>
                                                <span class="sBtn">

                                                  <a rel="nofollow" class="redbtn apc" target="_blank" href="//cosme.pclady.com.cn/pingce/110427.html">
                                                                                                                                                看评测
                                                  </a>

                                                  <a class="redbtn aZang" href="javascript:void(0)" onclick="common.upProduct(110427, this)"><em class="zang">感兴趣(68)</em><em class="nub">+1</em></a>
                                                  <a rel="nofollow" class="redbtn aDP" target="_blank" href="//cosme.pclady.com.cn/product/110427.html">
                                                                                                                                          去点评
                                                  </a>
                                               </span>
                                            </i>
                                        </li>
                                    </c:if>

                                    <li${index.first ? ' class="first"' : ''}>
                                     <i class="sum sum${index.count > 4 ? index.count + 1 : index.count}"></i>
                                    <i class="iBox" id="input${p.id}">
                                    <a href="javascript:;" class="addId" onclick="common.addToBox(this);" value="${p.id},${p.name},${t:replaceHttpWeb(p.image)},${t:replaceHttpWeb(ROOT)}/product/${p.id}.html"><em>加入对比</em>
                                    </a>
                                        <a href="javascript:void(0)" class="deleteon" style="display: none" onclick="common.deleteCompare(${p.id},this);common.updateCompareCookie(${p.id});common.updatePro();">取消对比</a>
                                    </i> 
                                        <i class="iPic">
                                        <!-- 是否正在试用 -->
                                                                              
                                        <a href="${t:replaceHttpWeb(ROOT)}/product/${p.id}.html" target="_blank">
                                        <img src="${t:replaceHttpWeb(p.image)}" title="${p.brand.name} ${p.name}" width="200" height="200"> </a> </i> 
                                                <i class="iInfo"> 
                                                <span class="sTit">
                                                    <a href="${t:replaceHttpWeb(ROOT)}/product/${p.id}.html" title="${p.name}" target="_blank">${p.brand.name} ${p.name}</a> 
                                                </span> 
                                                <span class="sKey">                                              
                                                <a href="${t:replaceHttpWeb(ROOT)}/${p.brand.domain}.html" target="_blank">${p.brand.name}<i></i>
											    </a> 
											    <a href="${t:replaceHttpWeb(ROOT)}/products_list/br0_bs0_bi${p.bigSortId}_sm0_ef0_pb0_pe0_or0.html" target="_blank">${p.bigSort.name}<i></i>
											    </a> 
											    <a href="${t:replaceHttpWeb(ROOT)}/products_list/br0_bs0_bi0_sm${p.smallSortId}_ef0_pb0_pe0_or0.html" target="_blank">${p.smallSort.name}<i></i>
											    </a> 									
											<c:if test="${!empty p.efficacies}">
											<a href="${t:replaceHttpWeb(ROOT)}/products_list/br0_bs0_bi0_sm0_ef${p.efficacies.get(0).id}_pb0_pe0_or0.html" target="_blank">${p.efficacies.get(0).name}<i></i>
											</a> 
											</c:if>                                           
                                            </span>                                       
                                            <span class="sPay">参考价格：<em>￥<fmt:formatNumber type="number" value="${p.price}" maxFractionDigits="0"/></em>  产品规格：${fn:length(p.specs)>0 ? p.specs :'暂无'}</span>                                                                                        
                                             <span class="sDP">                                                                        
                                             <c:if test="${!empty reason && index.first}">
                                             <p>  
                                             <span>榜首理由 ：</span>${fn:replace(fn:replace(reason,'<', '&lt;'),'>','&gt;')}
                                             </p>
                                             </c:if>                                            
                                             <c:if test="${!empty oneComment}">
                                             <c:forEach var="comment" items="${!empty reason && index.first ? oneComment : p.getComments(2)}"> 
                                             <p>                                          
                                             <span>${comment.account.accountId>0 ? comment.account.nickName : (empty comment.account || comment.account.accountId==0) ? comment.name : ''}：</span>
                                             <a href="${t:replaceHttpWeb(ROOT)}${comment.link}" target="_blank">${cosme:subbytesGBK(comment.intro,90)}...</a>                                            
                                             </p>
                                             </c:forEach>
                                             </c:if>
                                             <c:if test="${empty oneComment}">
                                              <p>  
												网友点评：还没人抢到第一条点评，<a href="${t:replaceHttpWeb(ROOT)}/product/${p.id}.html" target="_blank" rel="nofollow" class="line">快去点评</a>
											  </p>
											 </c:if>
                                             </span>                                                                                     
                                            </i>
                                            <i class="iFix"> <span class="sCon"></span>                             
                                               <span class="sNub">评分：<em>${cosme:subbytesGBK(p.productStat.pcScoreF,3)}</em></span> 
                                               <span class="module_cmt_scoreStar"><span class="score_star" data-score="${cosme:subbytesGBK(p.productStat.pcScoreF,3)}"></span></span>
                                               <span class="sNub">点评：<em class="fs14"><fmt:formatNumber value="${p.solrCommentNum }" groupingUsed="true"/></em>条</span> 
                                               <span class="sBtn">
                                                  <c:if test="${!empty p.detailActicle}">
                                                  <a rel="nofollow" class="redbtn apc" target="_blank" href="${t:replaceHttpWeb(ROOT)}/pingce/${p.id}.html">
                                                                                                                                                看评测
                                                  </a>
                                                  </c:if>  
                                                  <a class="redbtn aZang" href="javascript:void(0)" onclick="common.upProduct(${p.id}, this)"><em class="zang">感兴趣(${p.productStat.commentUpNum})</em><em class="nub">+1</em></a> 
                                                  <a rel="nofollow" class="redbtn aDP" target="_blank" href="${t:replaceHttpWeb(ROOT)}/product/${p.id}.html">
                                                                                                                                          去点评
                                                  </a>
                                               </span> 
                                            </i> 
                                        </li>    
                                        </c:forEach>                                                            
                                 </ul>
                                 </c:if>
                                  <c:if test="${empty products}">
                                   <p class="pSorry"><i></i>很抱歉，该筛选条件下暂无结果。请重新设置筛选条件。</p><!-- 没有数据显示这个  -->
                                  </c:if>                                                    
                        </div>

                        <div class="clear"></div>                       
                    </div>
                    </memcached:cache>
                  <memcached:cache key="product_sort_hot_pro_xg_csListId${csListId}_bigSortId${bigSortId}_smallSortId${smallSortId}" time="6452" refresh="${param.refresh}">  
                   <c:if test="${csListId <= 0 && (bigSortId > 0 || smallSortId > 0)}">
                  <%
          	      SearchProductService searchProductS = new SearchProductService();
                  Map<String, String> paramsMap = new HashMap<String, String>();
                  paramsMap.put("bigSortId", String.valueOf(bigSortId));
          		  paramsMap.put("smallSortId", String.valueOf(smallSortId));
          		  QueryResponse queryResponse = searchProductS.searchProductResponse(null,paramsMap, 0, true, true, 1, 10,false);
        		  List<JSONObject> listProduct = searchProductS.getJSONObjectByResponse(null,queryResponse,1,0);
        		  Map<String,Object> topMap = searchProductS.getCluster(queryResponse,false);      		 
      			  JSONArray efficacyArray = searchProductS.getEfficacyJson(topMap,null);
      			  request.setAttribute("efficacyArray",efficacyArray); 
      			  JSONArray brandArray = searchProductS.getBrandJson(topMap,null);
			      request.setAttribute("brandArray", brandArray);
		        %>
		         <c:if test="${(!empty efficacyArray && fn:length(efficacyArray)> 0) || (!empty brandArray && fn:length(brandArray)>0)}">
                    <div class="firend">
                    <div class="layAB fl">
                        <div class="module_allAsk_somePros mb-40">
                            <div class="module-tab">
                                <div class="module_tab_title clearfix">
                                    <ul>
                                        <li class="current">
                                            <a href="javascript:;">相关产品</a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="module_tab_content">
                                    <div class="module_tab_pannel">
                                        <div class="module_allAsk_somePros_list clearfix">
                                          <c:if test="${!empty efficacyArray && fn:length(efficacyArray)>0}">
                                            <c:forEach var="item" items="${efficacyArray}" varStatus="index" begin="0" end="9">    
                                               <a href="${t:replaceHttpWeb(ROOT)}/products_list/br0_bs0_bi${bigSortId}_sm${smallSortId}_ef${item.id}_pb0_pe0_or0.html" target="_blank">${item.name}${titleName}</a>
                                            </c:forEach>
                                           </c:if>
                                           <c:if test="${!empty brandArray && fn:length(brandArray)>0}">
                                            <c:forEach var="item" items="${brandArray}" varStatus="index" begin="0" end="9">    
                                               <a href="${t:replaceHttpWeb(ROOT)}/products_list/br${item.id}_bs0_bi${bigSortId}_sm${smallSortId}_ef0_pb0_pe0_or0.html" target="_blank">${item.name}${titleName}</a>
                                            </c:forEach>
                                           </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>  
                    </div>
                </div>
             </c:if>
             </c:if>
             </memcached:cache>
           </div>
       </div>
      </div>
  </div>



<div class="cosme_slideNav" >
    <div id="basketProduct">
  <form name="compareForm" target="_blank" id="compareForm" action="//cosme.pclady.com.cn/products_compare.html" method="post">
</form>



</div>

<div id="contrastBtn" class="conBtn" onclick="common.openBasket();">
    <i class="iNub iProNum">0</i><span><!-- VS --></span>
</div>
<ul class="sCz">

                <li class="s_cwap">
                    <a href="javascript:;">
                        <div class="s_ma" style="display: none;">
                            <div class="s_ma_cont">
                                <img src="//www1.pclady.com.cn/global/2013/images_i/md/hzp_gcode.png" height="148" width="150">
                                <span>查看化妆品库手机版</span>
                            </div>
                            <em></em>
                        </div>
                    </a>
                </li>
                <li class="s_cother">
                    <a href="javascript:;">
                        <div class="s_ma" style="display: none;">
                            <div class="s_ma_cont">
                                <img src="//www1.pclady.com.cn/global/2017/cosme/other_ma.png" height="142" width="140">
                                <span>关注小程序"美妆买什么"</span>
                            </div>
                            <em></em>
                        </div>
                    </a>
                </li>
                <li class="s_backTop"><a href="javascript:window.scrollTo(0,0)"></a></li>
            </ul>
    </div>


    <div id="contrastBox" class="conBox" style="display: none" >
    <div class="th">
        <span class="mark"><strong>对比中的产品</strong> (<em class="iProNum">0</em>/4)</span>
        <span class="subMark" onclick="common.closeBasket();"></span>
    </div>
    <div class="tb">
        <ul id="compareUl">
             
        </ul>
        <p class="pTxt" id="pNoCompare" >
            您还未作选择，先去选择的宝贝吧~
        </p>
        <p class="pBtn">
            <a href="javascript:void(0)" class="aRast compareOptionButton">开始对比</a><a href="javascript:void(0)" class="aDelT" onclick="common.deleteAllCompare();">清空产品</a>
        </p>
        <div class="clear">
        </div>
    </div>
</div>
    <script src="//js.3conline.com/min/temp/v1/lib-jquery1.10.2.js"></script>
    <script src="//js.3conline.com/js/pclady/lady2017/cosme/common.js"  charset="UTF-8"></script>
 	<script type="text/javascript" src="//js.3conline.com/js/pclady/lady2017/cosme/rank.js"></script>
     <script> 
     common.scoreStar();
     common.initCompareUI();
    </script>
        
    <%@include file="/global_ssi/pclady/footer/index.html" %>
    <script>_submitIvyID();</script>
</body>
</html>