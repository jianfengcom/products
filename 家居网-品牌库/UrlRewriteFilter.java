package cn.pconline.houselib.util;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import cn.pconline.cms.domain.MyChannel;
import cn.pconline.cms.domain.ParentChannelEnum;
import cn.pconline.houselib.domain.Brand;
import cn.pconline.houselib.domain.Category;
import cn.pconline.houselib.domain.ProductEntity;

public class UrlRewriteFilter implements Filter {

	private static final String TEMPLATE_PATH = "/jsp/template/";
	private static final Pattern PRODUCT_PATTERN = Pattern.compile("/item/(\\d+)(_(picture|detail|comment))?(_(\\d+))?\\.html");
	private static final Pattern BRAND_PATTERN = Pattern
			.compile("/(brand)/((\\d+)/((comment|introduction|)(_(\\d+))?\\.html)?)?");
	private static final String LIST_BRAND_STRING = "/list/brand/";
	private static final Pattern BRAND_RECOMMEND_PATTERN = Pattern.compile("/(recommand)/((\\d+)(_(\\d+))?\\.html)?");
	// http://product.pcbaby.com.cn/list/b12_c123_s8_f12_f23_p14_o1_20.html
///	private static final Pattern INDEX_PATTERN = Pattern
///			.compile("/list/((b(\\d+)(_)?){0,})(c(\\d+)(_)?)?(s(\\d+)(_)?)?(a(\\d+)(_)?)?((f(\\d+)(_)?){0,})((p(\\d+)_ps([0-9\\.]+)_pe([0-9\\.]+))(_)?)?(o(\\d+)(_)?)?(\\d+)?(\\.html)?(.*)");
	private static final Pattern INDEX_PATTERN = Pattern
			.compile("/list/((b(\\d+)(_)?){0,})(c(\\d+)(_)?)?(s(\\d+)(_)?)?(a(\\d+)(_)?)?((f(\\d+)(_)?){0,})" +
			"((p(\\d+)_ps([0-9\\.]+)_pe([0-9\\.]+))(_)?)?(o(\\d+)(_)?)?(\\d+)?\\.html");///为防止输入非法参数仍然可以跳转到正常页面，规定.html为必须输入
	private static final Pattern MULTI_INDEX_PATTERN = Pattern
			.compile("/multi/list/((b(\\d+)(_)?){0,})(c(\\d+)(_)?)?(s(\\d+)(_)?)?(a(\\d+)(_)?)?((f(\\d+)(_)?){0,})((p(\\d+)_ps([0-9\\.]+)_pe([0-9\\.]+))(_)?)?(o(\\d+)(_)?)?(\\d+)?(\\.html)?(.*)");
	// http://product.pchouse.com.cn/weiyu/list/b1_b2_f1_f2_o1_e1_r1_pb1_pe1_20.html
	// b:brand f:option o:order e:express(是否快递) r:refund(是否无条件退款) pb:priceBegin
	// private static final Pattern BATH_ROOM_INDEX_PATTERN =
	private static final Pattern PK_PATTERN = Pattern.compile("/pk/(\\d+)_(\\d+)\\.html");
	private static final Pattern TOP_INDEX_PATTERN = Pattern.compile("/top/"); // 推荐排行榜
	private static final Pattern TOP_PATTERN = Pattern.compile("/top/(b|c|n)?(\\d+)?\\.html"); // 排行榜
	private static final Pattern PATTERN_360 = Pattern.compile("/360/((\\d+)?(list_(\\d+))?\\.html)?"); // 360创意单品
	private static final Pattern PATTERN_INDEX = Pattern.compile("/360/(loading|space|color|style|material)\\.html");
	private static final Pattern PATTERN_360_PRODUCT = Pattern
			.compile("/360/(item|list)/(k(\\d+)_)?(y(\\d+)_)?(f(\\d+)_)?(c(\\d+)_)?(b(\\d+)_)?(\\d+)+\\.html");
	private static final Pattern PATTERN_QQ = Pattern
			.compile("/qq/(item|list)/(k(\\d+)_)?(y(\\d+)_)?(f(\\d+)_)?(c(\\d+)_)?(b(\\d+)_)?(\\d+)+\\.html"); // QQ创意单品
	private static final Pattern PATTERN_QQ_INDEX = Pattern.compile("/qq/(loading|space|color|style|material)\\.html");
	private static final Pattern CMS_LIST = Pattern.compile("/cms/(.*)/(((_)?\\d+){0,})(_o(\\d+))?(_d(\\d+))?(_p((\\d+)))?.html");
	private static final Pattern PATTER_BROOM_WEIYU = Pattern.compile("/weiyu/(qd|brand|tj|agent|listdetail)/?((.*).html)?");
	private static final Pattern PATTER_BROOM_QD = Pattern.compile("/weiyu/qd/?(pf|st|bq|dd)/?((.*).html)?");
	private static final Pattern PATTERN_BROOM_BTOPIC = Pattern.compile("/weiyu/tj/(\\d+)?(p(\\d+))?\\.html");
	private static final Pattern PATTERN_BROOM_AGENT = Pattern.compile("/shangjia/b(\\d+)/?(d(\\d+)/)?((.*).html)?");
	private static final Pattern PRODUCT_PATTERN_PRICE = Pattern.compile("/item/(\\d+)(_(lineoff|lineon))?\\.html");

	private static final String SITEMAP_PATH = "/list/";

	//private static final Pattern ACTIVITY_PATH  = Pattern.compile("/activity/(.*)\\.html");//活动b1060_t108_kidsroom.html
	private static final Pattern ACTIVITY_PATH  = Pattern.compile("/activity/b(\\d+)/t(\\d+)_(.*).html");
	private static final Pattern KMS_LIST_PATH = Pattern.compile("/kms/kms_list.html");
	private static final Pattern KMS_SEARCH_PATH = Pattern.compile("/kms/kms_search/(\\d+)_(\\d+).html");


	//--------------------------------------------【WAP START】-----------------------------------------------------
	private static final Pattern WAP_PRODUCT_PATTERN = Pattern.compile("/product/item/(\\d+)\\.html");
//	private static final Pattern WAP_BRAND_PATTERN = Pattern.compile("/product/brand/(\\d+)/");
///	private static final Pattern LIST_WAP_PATTERN = Pattern
///			.compile("/product/list/((b(\\d+)(_)?){0,})(c(\\d+)(_)?)?(s(\\d+)(_)?)?(a(\\d+)(_)?)?((f(\\d+)(_)?){0,})((p(\\d+)_ps([0-9\\.]+)_pe([0-9\\.]+))(_)?)?(o(\\d+)(_)?)?(\\d+)?(\\.html)?(.*)");
	private static final Pattern LIST_WAP_PATTERN = Pattern
			.compile("/product/list/((b(\\d+)(_)?){0,})(c(\\d+)(_)?)?(s(\\d+)(_)?)?(a(\\d+)(_)?)?"+
			"((f(\\d+)(_)?){0,})((p(\\d+)_ps([0-9\\.]+)_pe([0-9\\.]+))(_)?)?(o(\\d+)(_)?)?(\\d+)?\\.html");///为防止输入非法参数仍然可以跳转到正常页面，规定.html为必须输入
	private static final String SEARCH_WAP_PATH = "/product/search/";
	private static final String SEARCH_LIST_WAP_PATH = "/product/search_list/";
	private static final String LIST_WAP_PATH = "/product/list_search/";
	private static final String LIST_WAP_BRAND = "/product/list/brand/";
	private static final Pattern WAP_TOP_PATTERN = Pattern.compile("/product/top/((b|c|n)?(\\d+)\\.html)?$"); // 排行榜
	private static final Pattern WAP_TOP_DETAIL_PATTERN = Pattern.compile("/product/top/item/(b|c|n)(\\d+)\\.html"); // 排行榜
	private static final Pattern WAP_INDEX = Pattern.compile("/product(/[\\s\\S]*)");
	//品牌专区
	private static final Pattern WAP_BRAND_ZQ = Pattern.compile("/product/brand/(\\d+)/(([\\w\\d_]+)\\.html)?$");
	//--------------------------------------------【WAP END】-----------------------------------------------------

	@Override
	public void init(FilterConfig config) throws ServletException {

	}

	public static void main(String[] args) {
		Matcher matcher = CMS_LIST.matcher("/cms/case/1_20_14_o2.html");
		if (matcher.matches()) {
			for (int i = 0; i < matcher.groupCount(); i++) {
				System.out.println(i + "--" + matcher.group(i));
			}
		}
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws ServletException,
			IOException {
		HttpServletRequest hRequest = ((HttpServletRequest) request);
		HttpServletResponse hResponse = ((HttpServletResponse) response);

		String uri = hRequest.getRequestURI();
		uri = uri.replaceAll("/+", "/");

		StringBuffer forwardBuffer = new StringBuffer();

		// sitemap--------------------------
		if (uri.equals(SITEMAP_PATH)) {
			forwardBuffer.append("/jsp/template/product/").append("sitemap.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}

		if (uri.equals(LIST_BRAND_STRING)) {
			// forwardBuffer.append(TEMPLATE_PATH + "listBrand.jsp");
			forwardBuffer.append("/jsp/template/brand/" + "brandPrice.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}
		Matcher matcher = PRODUCT_PATTERN.matcher(uri);

		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String pId = matcher.group(1);
			String page = matcher.group(3);

			int offset = NumberUtils.toInt(matcher.group(5), 0);

			page = page == null ? "" : page.toLowerCase();
			// 判断是否卫浴产品
			ProductEntity entity = ProductEntity.load(NumberUtils.toInt(pId));
			if (entity != null) {
				// 非卫浴产品
				if (page != "") {
					forwardBuffer.append("/jsp/template2010/");
					forwardBuffer.append("item" + StringUtils.firstToUpper(page) + ".jsp?pId=").append(pId).append("&offset=")
							.append(offset);
				} else {
					forwardBuffer.append("/jsp/template/product/");
					// 判断是否重点产品
					if (entity.getIsImport() == ProductEntity.IS_IMPORT_PRODUCT) {
						forwardBuffer.append("important_product" + StringUtils.firstToUpper(page) + ".jsp?pId=").append(pId)
								.append("&offset=").append(offset);
					} else {
						forwardBuffer.append("star_product" + StringUtils.firstToUpper(page) + ".jsp?pId=").append(pId)
								.append("&offset=").append(offset);
					}
				}
			} else {
				forwardBuffer.append("/404.html");
			}

			goForward(forwardBuffer, request, response);
			return;
		}

		matcher = BRAND_PATTERN.matcher(uri);

		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String list = matcher.group(1);
			int bId = NumberUtils.toInt(matcher.group(3), 0);
			String page = matcher.group(5);
			int offset = NumberUtils.toInt(matcher.group(7), 0);

			if ("brand".equals(list) && bId == 0) {
				forwardBuffer.append("/jsp/template/brand/").append("brandList.jsp");
				goForward(forwardBuffer, request, response);
				return;
			}

			page = page == null ? "" : page.toLowerCase();
			Brand brand = Brand.load(bId);
			if (brand != null) {
				//索菲亚大牌管（特殊页面）
				if (brand.getId() == 1060) {
					forwardBuffer.append("/jsp/template/brand/suofeiyaBrand.jsp?bId=").append(bId);
					goForward(forwardBuffer, request, response);
					return;
				}
				if(brand.getIsSpecialZone()==1){
					forwardBuffer.append("/jsp/template/brand/specialBrand.jsp?bId=").append(bId);
					goForward(forwardBuffer, request, response);
					return;
				}
				forwardBuffer.append("/jsp/template/brand/");
				if (StringUtils.isNotBlank(page)) {
					forwardBuffer.append(page + ".jsp?bId=").append(bId);
				} else {
					if(brand.getType() == Brand.TYPE_BIG){ //大牌管
						forwardBuffer.append("bigBrand.jsp?bId=").append(bId);
					} else if(brand.getType() == Brand.TYPE_IMPORTANT){	///判断是否重点品牌
						forwardBuffer.append("importantBrand.jsp?bId=").append(bId);
					}else{
						forwardBuffer.append("brand.jsp?bId=").append(bId);
					}
				}
				forwardBuffer.append("&offset=").append(offset);
			} else {
				forwardBuffer.append("/404.html");
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		//品牌推荐页和重点品牌推荐页
		matcher = BRAND_RECOMMEND_PATTERN.matcher(uri);
		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String list = matcher.group(1);
			int cId = NumberUtils.toInt(matcher.group(3), 0);
			int pageNo = NumberUtils.toInt(matcher.group(5), 1);

			if ("recommand".equals(list) && cId > 0) {
				forwardBuffer.append("/jsp/template/brand/").append("brandRecommendList.jsp?cId=");
				forwardBuffer.append(cId);
				forwardBuffer.append("&pageNo=").append(pageNo);
				goForward(forwardBuffer, request, response);
				return;
			}
		}

		// 索引页面
		if (uri.indexOf("/list/") != -1) {
			boolean isMultiBrand = true;
			matcher = MULTI_INDEX_PATTERN.matcher(uri);
			if (!matcher.matches()) {
				matcher = INDEX_PATTERN.matcher(uri);
				isMultiBrand = false;
			}
			if (matcher.matches()) {
				forwardBuffer.setLength(0);
				String bIds = matcher.group(1);
				String cId = matcher.group(6);
				String sId = matcher.group(9);
				String aId = matcher.group(12);
				String filters = matcher.group(14);

				int[] bId = null;
				if (!StringUtils.isBlank(bIds)) {
					String[] bIdArr = bIds.split("_");
					bId = new int[bIdArr.length];
					int i = 0;
					for (String brandId : bIdArr) {
						bId[i] = NumberUtils.toInt(brandId.substring(1));
						i++;
					}
				}

				int[] fId = null;
				if (!StringUtils.isBlank(filters)) {
					String[] filterArr = filters.split("_");
					fId = new int[filterArr.length];
					int i = 0;
					for (String filter : filterArr) {
						fId[i] = NumberUtils.toInt(filter.substring(1));
						if(i > 0){	///对fId参数进行判断，规定从小到大，不符合为非法uri
							if(fId[i] < fId[i-1]){
								forwardBuffer.append("/404.html");
								goForward(forwardBuffer, request, response);
								return;
							}
						}
						i++;
					}
				}

				String price = matcher.group(20);
				String ps = matcher.group(21);
				String pe = matcher.group(22);
				String order = matcher.group(25);
				String offset = matcher.group(27);
				//String otherParam = matcher.group(29);
				// 判断是否卫浴馆
				boolean isBathroom = false;
				if (isBathroom) {
					forwardBuffer.append("/jsp/modules/bathroom/").append("list.jsp?");
				} else {
					forwardBuffer.append("/jsp/template/product/").append("list.jsp?");
				}
				if (bId != null) {
					for (int b : bId) {
						forwardBuffer.append("&bId=").append(b);
					}
				}
				if (!StringUtils.isBlank(cId)) {
					forwardBuffer.append("&cId=").append(cId);
				}
				if (!StringUtils.isBlank(sId)) {
					forwardBuffer.append("&sId=").append(sId);
				}
				if (!StringUtils.isBlank(aId)) {
					forwardBuffer.append("&aId=").append(aId);
				}
				if (fId != null) {
					for (int s : fId) {
						forwardBuffer.append("&fId=").append(s);
					}
				}
				if (!StringUtils.isBlank(price)) {
					forwardBuffer.append("&price=").append(price);
				}
				if (!StringUtils.isBlank(ps)) {
					forwardBuffer.append("&ps=").append(ps);
				}
				if (!StringUtils.isBlank(pe)) {
					forwardBuffer.append("&pe=").append(pe);
				}
				if (!StringUtils.isBlank(order)) {
					forwardBuffer.append("&order=").append(order);
				}
				if (!StringUtils.isBlank(offset)) {
					forwardBuffer.append("&offset=").append(offset);
				}
				if (isMultiBrand) {
					forwardBuffer.append("&multi=").append(1);
				}
				//if (!StringUtils.isBlank(otherParam)) {
				//	forwardBuffer.append("&").append(otherParam);
				//}

				goForward(forwardBuffer, request, response);
				return;
			}
		}

		// pk页面
		if (uri.indexOf("/pk/") != -1) {
			matcher = PK_PATTERN.matcher(uri);
			if (matcher.matches()) {
				int id1 = NumberUtils.toInt(matcher.group(1));
				int id2 = NumberUtils.toInt(matcher.group(2));
				if (id1 > id2) {
					String pkUrl = UrlMap.getPkUrl(id1, id2);
					hResponse.sendRedirect(pkUrl);
					return;
				}
				forwardBuffer.setLength(0);
				forwardBuffer.append(TEMPLATE_PATH).append("pk.jsp?");
				forwardBuffer.append("id=").append(id1).append("&id=").append(id2);
				goForward(forwardBuffer, request, response);
				return;
			}
		}

		// 产品比较页面
		if (uri.indexOf("/compare.html") != -1) {
			forwardBuffer.setLength(0);
			// forwardBuffer.append(TEMPLATE_PATH).append("itemCompare.jsp?");
			String id = request.getParameter("id");
			if (id != null) {
				ProductEntity entity = ProductEntity.load(NumberUtils.toInt(id));
				if (entity != null) {
					Category category = Category.load(entity.getCategoryId());
					if (category != null && category.getParentId() == 10) {
						// 卫浴产品对比页
						forwardBuffer.append("jsp/modules/bathroom/").append("compare.jsp?");
					} else {
						// 其他产品对比页
						forwardBuffer.append("/jsp/template/product/").append("compare.jsp?");
					}
				}
			}
			request.getRequestDispatcher(forwardBuffer.toString()).forward(request, response);
			return;
		}

		matcher = TOP_INDEX_PATTERN.matcher(uri);
		if (matcher.matches()) {
			forwardBuffer.append(TEMPLATE_PATH).append("top/index.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}
		//排行榜
		matcher = TOP_PATTERN.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			int id = NumberUtils.toInt(matcher.group(2));
			String path = "";
			if ("c".equals(type) || "b".equals(type) || "n".equals(type)) {
				Category categoryForTop = Category.load(id);
				Category topCategoryForTop = null;
				if (categoryForTop != null) {
					topCategoryForTop = categoryForTop.getTopParent();
				}
				if (categoryForTop != null && topCategoryForTop != null) {
					if ((categoryForTop.isSmall() || categoryForTop.isMid()) && categoryForTop.getIsShow() == 1 && topCategoryForTop.getIsShow() == 1) {
						path = "top/top_list.jsp?cId=" + id + "&value=" + type;
					} else {
						if ("b".equals(type)) {
							path = "top/brand.jsp?bId=" + id;
						} else if ("c".equals(type)) {
							path = "top/product.jsp?cId=" + id;
						} else {
							hResponse.sendError(404);
							return;
						}
					}
				} else {
					hResponse.sendError(404);
					return;
				}
			} else if (StringUtils.isEmpty(type)){
				hResponse.sendError(404);
				return;
			}

			forwardBuffer.append(TEMPLATE_PATH).append(path);
			goForward(forwardBuffer, request, response);
			return;
		}


		// 360创意单品--------------(改版前)
		matcher = PATTERN_360.matcher(uri);
		if (matcher.matches()) {
			int id = NumberUtils.toInt(matcher.group(2));
			int pageNo = NumberUtils.toInt(matcher.group(4));
			forwardBuffer.append("/jsp/partner/360/");
			if (0 == id && 0 == pageNo) {
				forwardBuffer.append("index.jsp");
			} else if (0 < id) {
				forwardBuffer.append("art.jsp?id=" + id);
			} else {
				forwardBuffer.append("list.jsp?pageNo=" + pageNo);
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		// 改版后 ----------------------------
		// 360创意单品Index
		matcher = PATTERN_INDEX.matcher(uri);
		if (matcher.matches()) {
			String pageType = matcher.group(1);
			forwardBuffer.append("/jsp/partner/360/");
			if ("space".equals(pageType)) {
				forwardBuffer.append("space.jsp");
			} else if ("color".equals(pageType)) {
				forwardBuffer.append("color.jsp");
			} else if ("style".equals(pageType)) {
				forwardBuffer.append("style.jsp");
			} else if ("material".equals(pageType)) {
				forwardBuffer.append("material.jsp");
			} else if ("loading".equals(pageType)) {
				forwardBuffer.append("loading.jsp");
			}

			goForward(forwardBuffer, request, response);
			return;
		}

		// 360创意单品
		matcher = PATTERN_360_PRODUCT.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			int space = NumberUtils.toInt(matcher.group(3));
			int color = NumberUtils.toInt(matcher.group(5));
			int style = NumberUtils.toInt(matcher.group(7));
			int material = NumberUtils.toInt(matcher.group(9));
			int brand = NumberUtils.toInt(matcher.group(11));
			int num = NumberUtils.toInt(matcher.group(12), 1);
			forwardBuffer.append("/jsp/partner/360/");

			// 列表页：num表示第几页；终端页：num表示第几个产品
			if ("list".equals(type)) {
				forwardBuffer.append("list2.jsp?pageNo=" + num);
			} else if ("item".equals(type)) {
				forwardBuffer.append("art2.jsp?id=" + num);
			}

			if (space > 0) {
				forwardBuffer.append("&space=" + space);
			}
			if (color > 0) {
				forwardBuffer.append("&color=" + color);
			}
			if (style > 0) {
				forwardBuffer.append("&style=" + style);
			}
			if (material > 0) {
				forwardBuffer.append("&material=" + material);
			}
			if (brand > 0) {
				forwardBuffer.append("&brand=" + brand);
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		// 改版后 ----------------------------
		// QQ创意单品Index
		matcher = PATTERN_QQ_INDEX.matcher(uri);
		if (matcher.matches()) {
			String pageType = matcher.group(1);
			forwardBuffer.append("/jsp/partner/qq/");
			if ("space".equals(pageType)) {
				forwardBuffer.append("space.jsp");
			} else if ("color".equals(pageType)) {
				forwardBuffer.append("color.jsp");
			} else if ("style".equals(pageType)) {
				forwardBuffer.append("style.jsp");
			} else if ("material".equals(pageType)) {
				forwardBuffer.append("material.jsp");
			} else if ("loading".equals(pageType)) {
				forwardBuffer.append("loading.jsp");
			}

			goForward(forwardBuffer, request, response);
			return;
		}

		// QQ创意单品
		matcher = PATTERN_QQ.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			int space = NumberUtils.toInt(matcher.group(3));
			int color = NumberUtils.toInt(matcher.group(5));
			int style = NumberUtils.toInt(matcher.group(7));
			int material = NumberUtils.toInt(matcher.group(9));
			int brand = NumberUtils.toInt(matcher.group(11));
			int num = NumberUtils.toInt(matcher.group(12), 1);
			forwardBuffer.append("/jsp/partner/qq/");

			// 列表页：num表示第几页；终端页：num表示第几个产品
			if ("list".equals(type)) {
				forwardBuffer.append("list2.jsp?pageNo=" + num);
			} else if ("item".equals(type)) {
				forwardBuffer.append("art2.jsp?id=" + num);
			}

			if (space > 0) {
				forwardBuffer.append("&space=" + space);
			}
			if (color > 0) {
				forwardBuffer.append("&color=" + color);
			}
			if (style > 0) {
				forwardBuffer.append("&style=" + style);
			}
			if (material > 0) {
				forwardBuffer.append("&material=" + material);
			}
			if (brand > 0) {
				forwardBuffer.append("&brand=" + brand);
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		if ("/weiyu/".equals(uri)) {
			forwardBuffer.append("/jsp/modules/bathroom/index.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}

		// 卫浴馆品牌专题清单
		matcher = PATTERN_BROOM_BTOPIC.matcher(uri);
		if (matcher.matches()) {
			int brandTopicId = NumberUtils.toInt(matcher.group(1), 0);
			String pageStr = matcher.group(2);
			forwardBuffer.append("/jsp/modules/bathroom/");
			if (brandTopicId > 0) {
				forwardBuffer.append("brandTopic.jsp?brandTopicId=" + brandTopicId);
			} else if (StringUtils.isNotEmpty(pageStr) && NumberUtils.toInt(pageStr.substring(1)) > 0) {
				forwardBuffer.append("brandTopicList.jsp?pageNo=" + NumberUtils.toInt(pageStr.substring(1)));
			} else {
				forwardBuffer.append("brandTopicList.jsp");
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		// 卫浴馆
		matcher = PATTER_BROOM_QD.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			String qddesc = matcher.group(2);
			forwardBuffer.append("/jsp/modules/bathroom/").append("brandlist.jsp");
			String topic = "1";
			String page = "1";
			// 类型
			String url1 = "";
			if (type != null) {
				if ("pf".equals(type)) {
					topic = "1";
					url1 = "/weiyu/qd/pf/";
				} else if ("st".equals(type)) {
					topic = "2";
					url1 = "/weiyu/qd/st/";
				} else if ("bq".equals(type)) {
					topic = "4";
					url1 = "/weiyu/qd/bq/";
				} else if ("dd".equals(type)) {
					topic = "5";
					url1 = "/weiyu/qd/dd/";
				}
			}
			// 页码
			if (qddesc != null) {
				page = qddesc.substring(qddesc.indexOf("_") + 1, qddesc.indexOf("."));
			}
			forwardBuffer.append("?topic=" + topic + "&&pageNo=" + page + "&&url1=" + url1);
			goForward(forwardBuffer, request, response);
			return;
		}

		matcher = PATTERN_BROOM_AGENT.matcher(uri);
		if (matcher.matches()) {
			String N1 = matcher.group(1);
			String N2 = matcher.group(3);
			String page = matcher.group(4);
			forwardBuffer.append("/jsp/modules/bathroom/").append("agent.jsp");
			if (N1 != null) {
				forwardBuffer.append("?brandId=" + N1);
			}
			if (N2 != null) {
				forwardBuffer.append("&&cityId=" + N2);
			}
			String p = "1";
			if (page != null) {
				p = page.substring(page.indexOf("_") + 1, page.indexOf("."));
			}
			forwardBuffer.append("&&pageNo=" + p);
			goForward(forwardBuffer, request, response);
			return;
		}

		matcher = PATTER_BROOM_WEIYU.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			String qddesc = matcher.group(2);
			if ("brand".equals(type)) {
				// 品牌页
				forwardBuffer.append("/jsp/modules/bathroom/").append("brand.jsp");
			}
			if ("qd".equals(type)) {
				// 清单页
				if ((qddesc != null && qddesc.indexOf("index") != -1) || (qddesc == null)) {
					// 清单列表分页
					forwardBuffer.append("/jsp/modules/bathroom/").append("brandlist.jsp");
					String url1 = "/weiyu/qd/";
					String page = "1";
					if (qddesc != null && qddesc.indexOf("index") != -1) {
						page = qddesc.substring(qddesc.indexOf("_") + 1, qddesc.indexOf("."));
					}
					forwardBuffer.append("?topic=" + 0 + "&&pageNo=" + page + "&&url1=" + url1);
				} else {
					// 清单终端页
					forwardBuffer.append("/jsp/modules/bathroom/").append("listDetail.jsp");
					String pid = qddesc.substring(0, qddesc.indexOf(".html"));
					forwardBuffer.append("?productipId=" + pid);
				}
			}
			if (uri.indexOf("tj") != -1) {
				forwardBuffer.append("/jsp/modules/bathroom/").append("brandTopicList.jsp");
			}
			goForward(forwardBuffer, request, response);
			return;
		}

		matcher = CMS_LIST.matcher(uri);
		if (matcher.matches()) {
			String enName = matcher.group(1);
			if (enName != null && !enName.equals("")) {
				MyChannel myChannel = MyChannel.loadByEnName(enName);
				if (myChannel != null) {
					// ?? 这里使用了枚举类的名称小写作为url中的一部分 不知道妥不妥当
					String parentChannelName = ParentChannelEnum.getStatusEnum(myChannel.getParentChannel()).name().toLowerCase();
					forwardBuffer.append("/cms/" + parentChannelName + "/list.jsp?");

					forwardBuffer.append("&enName=" + enName);

					String strOptions = matcher.group(2);
					String[] options = strOptions.split("_");
					for (String option : options) {
						forwardBuffer.append("&options=" + option);
					}
					String orderBy = matcher.group(6);
					forwardBuffer.append("&orderBy=" + orderBy);

					String display = matcher.group(8);
					forwardBuffer.append("&display=" + display);

					String pageNo = matcher.group(10);
					forwardBuffer.append("&pageNo=" + pageNo);
				}
			}
			goForward(forwardBuffer, request, response);
			return;
		}
		// 报价页
		matcher = PRODUCT_PATTERN_PRICE.matcher(uri);
		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String pId = matcher.group(1);
			//报价页跳到终端页
			hResponse.sendRedirect(Config.getInstance().getHost() + "/item/"+pId+".html");
		/*	String pId2 = matcher.group(2);
			if ("_lineoff".equals(pId2)) {
				forwardBuffer.append("/jsp/template/product/box/product_lineoff.jsp?pId=" + pId);
			}
			if ("_lineon".equals(pId2)) {
				forwardBuffer.append("/jsp/template/product/box/product_lineon.jsp?pId=" + pId);
			}
			goForward(forwardBuffer, request, response);*/
			return;
		}

		//活动页面
		matcher = ACTIVITY_PATH.matcher(uri);
		if (matcher.matches()) {
			String bId = matcher.group(1);
			String tId = matcher.group(2);
			String p = matcher.group(3);
			String path = "/jsp/template/activity/"+bId+"_"+p+".jsp?bId="+bId+"&tryoutId="+tId;
			forwardBuffer.append(path);
			goForward(forwardBuffer, request, response);
			return;
		}

		//关键字列表页【房产知识】
		matcher = KMS_LIST_PATH.matcher(uri);
		if(matcher.matches()){
			String path = "/jsp/kms/kms_list.jsp";
			forwardBuffer.append(path);
			goForward(forwardBuffer, request, response);
			return;
		}

		//关键字搜索结果页【房产知识】
		matcher = KMS_SEARCH_PATH.matcher(uri);
		if(matcher.matches()){
			String oId = matcher.group(1);
			String path = "/jsp/kms/kms_item.jsp?optionId="+oId;
			forwardBuffer.append(path);

			String pageNo = matcher.group(2);
			if (pageNo != null) {
				forwardBuffer.append("&pageNo=" + pageNo);
			}
			goForward(forwardBuffer,request,response);
			return;
		}


		// -----------------------------------------------【WAP页面START】------------------------------------------------
		matcher = WAP_BRAND_ZQ.matcher(uri);
		if(matcher.matches()) {
			forwardBuffer.setLength(0);
			String bId = matcher.group(1);
			if(uri.contains("goods.html")){
				String sortTit = "new";
				if(uri.contains("/hot")){
					sortTit = "hot";
				}else if(uri.contains("/spe")){
					sortTit = "spe";
				}else if(uri.contains("/cat")) {
					sortTit = matcher.group(3);
				}
				forwardBuffer.append("/jsp/wap/brand/goods.jsp?bId=" + bId+ "&sTit="+sortTit);
			}else if(uri.endsWith("/video.html")){
				forwardBuffer.append("/jsp/wap/brand/video.jsp?bId=" + bId);
			}else if(uri.endsWith("/zixun.html")){
				forwardBuffer.append("/jsp/wap/brand/zixun.jsp?bId=" + bId);
			}else if(uri.endsWith("/pingce.html")){
				forwardBuffer.append("/jsp/wap/brand/pingce.jsp?bId=" + bId);
			}else if(uri.endsWith("/zt.html")){
				forwardBuffer.append("/jsp/wap/brand/zt.jsp?bId=" + bId);
			}else if(uri.endsWith("/try.html")){
				forwardBuffer.append("/jsp/wap/brand/try.jsp?bId=" + bId);
			}else if(uri.endsWith("/effect.html")){
				forwardBuffer.append("/jsp/wap/brand/effect.jsp?bId=" + bId);
			}else {
				forwardBuffer.append("/jsp/wap/brand/sy.jsp?bId=" + bId);
			}

			goForward(forwardBuffer, request, response);
			return;
		}

		matcher = WAP_PRODUCT_PATTERN.matcher(uri);
		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String pId = matcher.group(1);
//			forwardBuffer.append("/jsp/wap/product/item.jsp?pId=" + pId);
			//2019-12-05 Wap端商品详情页改版
			forwardBuffer.append("/jsp/wap/product/item1.jsp?pId=" + pId);
			goForward(forwardBuffer, request, response);
			return;
		}

		// WAP 品牌大全
		if (uri.equals(LIST_WAP_BRAND)) {
			forwardBuffer.append("/jsp/wap/brand/list.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}

//		matcher = WAP_BRAND_PATTERN.matcher(uri);
//		if (matcher.matches()) {
//			forwardBuffer.setLength(0);
//			String bId = matcher.group(1);
//			forwardBuffer.append("/jsp/wap/brand/item.jsp?bId=" + bId);
//			goForward(forwardBuffer, request, response);
//			return;
//		}

		// WAP 查找页--------------------------
		if (uri.equals(SEARCH_WAP_PATH)) {
			forwardBuffer.append("/jsp/wap/product/").append("search.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}
		// WAP 查找结果页--------------------------
		if (uri.equals(SEARCH_LIST_WAP_PATH)) {
			forwardBuffer.append("/jsp/wap/product/").append("searchList.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}
		// WAP 列表首页--------------------------
		if (uri.equals(LIST_WAP_PATH)) {
			forwardBuffer.append("/jsp/wap/product/").append("list.jsp");
			goForward(forwardBuffer, request, response);
			return;
		}

		// WAP 列表页--------------------------
		matcher = LIST_WAP_PATTERN.matcher(uri);
		if (matcher.matches()) {
			forwardBuffer.setLength(0);
			String bIds = matcher.group(1);
			String cId = matcher.group(6);
			String sId = matcher.group(9);
			String aId = matcher.group(12);
			String filters = matcher.group(14);

			int[] bId = null;
			if (!StringUtils.isBlank(bIds)) {
				String[] bIdArr = bIds.split("_");
				bId = new int[bIdArr.length];
				int i = 0;
				for (String brandId : bIdArr) {
					bId[i] = NumberUtils.toInt(brandId.substring(1));
					i++;
				}
			}

			int[] fId = null;
			if (!StringUtils.isBlank(filters)) {
				String[] filterArr = filters.split("_");
				fId = new int[filterArr.length];
				int i = 0;
				for (String filter : filterArr) {
					fId[i] = NumberUtils.toInt(filter.substring(1));
					if(i > 0){	///对fId参数进行判断，规定从小到大，不符合为非法uri
						if(fId[i] < fId[i-1]){
							forwardBuffer.append("/404.html");
							goForward(forwardBuffer, request, response);
							return;
						}
					}
					i++;
				}
			}

			String price = matcher.group(20);
			String ps = matcher.group(21);
			String pe = matcher.group(22);
			String order = matcher.group(25);
			String offset = matcher.group(27);
			//String otherParam = matcher.group(29);
			forwardBuffer.append("/jsp/wap/product/").append("list.jsp?");

			if (bId != null) {
				for (int b : bId) {
					forwardBuffer.append("&bId=").append(b);
				}
			}
			if (!StringUtils.isBlank(cId)) {
				forwardBuffer.append("&cId=").append(cId);
			}
			if (!StringUtils.isBlank(sId)) {
				forwardBuffer.append("&sId=").append(sId);
			}
			if (!StringUtils.isBlank(aId)) {
				forwardBuffer.append("&aId=").append(aId);
			}
			if (fId != null) {
				for (int s : fId) {
					forwardBuffer.append("&fId=").append(s);
				}
			}
			if (!StringUtils.isBlank(price)) {
				forwardBuffer.append("&price=").append(price);
			}
			if (!StringUtils.isBlank(ps)) {
				forwardBuffer.append("&ps=").append(ps);
			}
			if (!StringUtils.isBlank(pe)) {
				forwardBuffer.append("&pe=").append(pe);
			}
			if (!StringUtils.isBlank(order)) {
				forwardBuffer.append("&order=").append(order);
			}
			if (!StringUtils.isBlank(offset)) {
				forwardBuffer.append("&offset=").append(offset);
			}
			//if (!StringUtils.isBlank(otherParam)) {
			//	forwardBuffer.append("&").append(otherParam);
			//}

			goForward(forwardBuffer, request, response);
			return;
		}

		//wap排行榜页面
/*		matcher = WAP_TOP_PATTERN.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(2);
			if (StringUtils.isEmpty(type)) {
				type = "b";
			}
			int id = NumberUtils.toInt(matcher.group(3));
			String path = "/jsp/wap/top/top_list.jsp?cId=" + id + "&value=" + type;
			if ("b".equals(type)) {
				path = "/jsp/wap/top/top_brand.jsp?cId=" + id;
			}
			forwardBuffer.append(path);
			goForward(forwardBuffer, request, response);
			return;
		}*/

		matcher = WAP_TOP_PATTERN.matcher(uri);
		if (matcher.matches()) {
			int id = NumberUtils.toInt(matcher.group(3));
			String path = "/jsp/wap/top";
			String type = matcher.group(2);
			if (!StringUtils.isEmpty(type) && "c".equalsIgnoreCase(type)) {
				path += "/product_index.jsp";
			}else {
				path += "/brand_index.jsp";
			}
			path += (id > 0? "?cateId="+id : "");

			forwardBuffer.append(path);
			goForward(forwardBuffer, request, response);
			return;
		}

		//wap排行榜详细页面
		matcher = WAP_TOP_DETAIL_PATTERN.matcher(uri);
		if (matcher.matches()) {
			String type = matcher.group(1);
			if (StringUtils.isEmpty(type)) {
				type = "b";
			}
			int id = NumberUtils.toInt(matcher.group(2));
			String path = "/jsp/wap/top/topDetail.jsp?cId=" + id + "&type=" + type;
			forwardBuffer.append(path);
			goForward(forwardBuffer, request, response);
			return;
		}

		// 最后匹配
		matcher = WAP_INDEX.matcher(uri);
		if (matcher.matches()) {
			String suffix = matcher.group(1);
			if ("/".equals(suffix)) {
				suffix = "/jsp/wap/index.jsp";
			} else if (suffix.contains("/WEB-INF")) {
				suffix = "/index.xhtm"; // 跳到不存在的页面，返回404
			}/*else if ("/index.html".equals(suffix)) {
				suffix = "/index.xhtm"; // 跳到不存在的页面，返回404
			}*/
			forwardBuffer.append(suffix);
			goForward(forwardBuffer, request, response);
			return;
		}
		// -----------------------------------------------【WAP页面END】------------------------------------------------
		chain.doFilter(request, response);
	}

	private void addQueryStr(StringBuffer buffer, ServletRequest request) {
		HttpServletRequest hRequest = ((HttpServletRequest) request);
		String queryStr = hRequest.getQueryString();
		if (!StringUtils.isBlank(queryStr)) {
			buffer.append(buffer.indexOf("?") != -1 ? "&" : "?").append(queryStr);
		}
	}

	private void goForward(StringBuffer buffer, ServletRequest request, ServletResponse response) throws ServletException,
			IOException {
		addQueryStr(buffer, request);
		String forward = buffer.toString();
		request.getRequestDispatcher(forward).forward(request, response);
	}

	@Override
	public void destroy() {

	}

}