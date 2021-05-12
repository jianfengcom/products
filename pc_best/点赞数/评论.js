$.ajax({
    url: 'http://cmt.pconline.com.cn/action/topic/get_data.jsp',
    data:{
        url:'http://best.pconline.com.cn/youhui/10158310.html' //文章页地址
    },
    dataType: "json",
    success: function(data) {
        console.log(data);
    }
});