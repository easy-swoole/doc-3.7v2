<!DOCTYPE html>
<html lang="cn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/default.min.css">
    <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"></script>
    <style>
        .fa-angle-right::before {
            padding-right:0.3rem
        }
        .fa-angle-down::before {
            padding-right:0.3rem
        }
        li{
            line-height: 1.7rem !important;
        }
        .sideBar-toggle-button {
            display: block;
            position: fixed;
            left: 10px;
            bottom: 15px;
            z-index: 99;
        }
        .right-menu{
            width: 230px;
            position: fixed;
            right: 15px;
            top: 120px;
            min-height: 1px;
            z-index: 99;
            border: 1px solid #EEEEEE;
            border-radius: 0 3px 3px 3px;
            background-color: #fff;
            padding: 10px;
            max-height: 70%;
            overflow-y: auto;
        }
        .right-menu::-webkit-scrollbar{
            display:none;
        }
        .right-menu > .title {
            color: #aaaaaa;
            background-color: #fff;
            width: 100%;
            right: 15px;
            padding-left: 0.1em;
            line-height: 200%;
            border-bottom: 1px solid #EEEEEE;
            cursor: pointer;
        }
        @media (max-width: 600px) {
            .right-menu {
                display:none;
            }
            #live2d-widget {
                display: none;
            }
        }

        .right-menu > li{
            list-style-type: none;
            padding-left:5px;
            padding-top: 5px;
        }
        .right-menu > li > a.active{
            color:#ff0006;
        }

        @media screen and (min-width: 700px) {
            .layout-2 .sideBar {
                width: 0 !important;
            }
            .layout-2 .mainContent {
                padding-left: 0 !important;
            }
            .navBar-menu-button {
                display: none;
            }
        }

        @media screen and (max-width: 700px) {
            .layout-1 .sideBar {
                width: 0 !important;
            }
            .layout-1 .mainContent {
                padding-left: 0 !important;
            }
            .container .navBar .navInnerRight {
                position: fixed !important;
                top: 3.6rem;
                left: 0 !important;
                right: 0 !important;
                padding: 0 1.5rem .5rem 1.5rem;
                display: none;
            }
            .navInnerRight > div {
                display: block !important;
                margin-left: 0 !important;
            }
            .navSearch > input {
                width: 100% !important;
                box-sizing: border-box;
            }
            .navBar-menu-button {
                display: block;
                float: right;
            }
            .sideBar-toggle-button {
                display: none;
            }
        }
    </style>
    <link rel="stylesheet" href="https://cdn.staticfile.org/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="/Css/content.css">
    <link rel="stylesheet" href="/Css/markdown.css">
</head>
<body>
<div class="container layout-1">
    <a class="sideBar-toggle-button" href="javascript:;">
        <i class="fa fa-bars" style="font-size: 1.3rem;color: #333;"></i>
    </a>
    <header class="navBar">
        <div class="navInner">
            <a href="/">
                <img src="/Images/docNavLogo.png" alt="">
            </a>
            <a class="navBar-menu-button" href="javascript:;">
                <i class="fa fa-bars" style="font-size: 1.3rem;color: #333;"></i>
            </a>
            <div class="navInnerRight">
                <div class="navSearch">
                    <input aria-label="Search" autocomplete="off" spellcheck="false" class="" placeholder="" id="SearchValue">
                    <div class="resultList" id="resultList" style="display: none"></div>
                </div>
                <div class="navItem">
                    <div class="dropdown-wrapper">
                        <a href="http://www.easyswoole.com/wstool.html" style="text-decoration:none;">websocket测试工具</a>
                    </div>
                </div>
            </div>
        </div>
    </header>
    <aside class="sideBar">{$sideBar}</aside>
    <section class="mainContent">
        <div class="content markdown-body">{$page.html}</div>
        <div class="right-menu" id="right-menu"></div>
    </section>
</div>

</body>



<script>
    hljs.highlightAll();
    $(document).ready(function() {
        /********** 左侧菜单栏开始 **************/
        $.each($('.sideBar li:has(li)'), function () {
            $(this).attr('isOpen', 0).addClass('fa fa-angle-right');
        });

        $('.sideBar li:has(ul)').click(function (event) {
            if (this == event.target) {
                $(this).children().toggle('fast');
                if ($(this).attr('isOpen') == 1) {
                    $(this).attr('isOpen', 0);
                    $(this).removeClass('fa fa-angle-down');
                    $(this).addClass('fa fa-angle-right');
                } else {
                    $(this).attr('isOpen', 1);
                    $(this).removeClass('fa fa-angle-right');
                    $(this).addClass('fa fa-angle-down');
                }
            }
        });
        // 自动展开菜单父级
        $.each($('.sideBar ul li a'), function () {
            $(this).filter("a").css("text-decoration", "none").css('color', '#2c3e50');
            if ($(this).attr('href') === window.location.pathname) {
                $(this).filter("a").css("text-decoration", "underline").css('color', '#0080ff');
                var list = [];
                var parent = this;
                while (1) {
                    parent = $(parent).parent();
                    if (parent.hasClass('sideBar')) {
                        break;
                    } else {
                        parent.click();
                    }
                }
            }
        });



        // 拦截菜单点击事件切换右侧内容
        $('.sideBar ul li a').on('click', function () {
            $.each($('.sideBar ul li a'), function () {
                $(this).filter("a").css("text-decoration", "none").css('color','#2c3e50');
            });
            $(this).filter("a").css("text-decoration", "underline").css('color','#0080ff');
            var href = $(this).attr('href');
            $.ajax({
                url: href,
                method: 'POST',
                success: function (res) {
                    window.history.pushState(null,null,href);
                    var newHtml = $(res);
                    document.title = newHtml.filter('title').text();
                    $('.markdown-body').html(newHtml.find('.markdown-body').eq(0).html());
                    hljs.initHighlighting.called = false;
                    hljs.highlightAll();
                    window.scrollTo(0, 0);
                }
            });
            return false;
        });


    });


</script>

</html>