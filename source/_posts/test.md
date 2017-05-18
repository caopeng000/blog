---
title: android TV开发之RecyclerView的使用以及自动加载
date: 2017-05-16 17:59:41
tags: android
---
![](http://ww1.sinaimg.cn/large/005Xtdi2jw1f9k7b8a6vmj312w0rg143.jpg)

recyclerview我就不做介绍了，相信大家一定已经非常熟悉它了，那今天我就来讲一下recyclerView在TV中的应用，总的来说，其实在TV中的使用与在手机上的使用并无太大的差别，唯一需要处理的可能就是一个焦点问题了.
<!--more-->
1.如何使用在TV中使用recyclerview来实现多样化的布局，这里的多样化布局就是跟腾讯视频首页那样的，分别有不同布局来组成一个界面，并向下滑动，，在手机上我们可以直接使用一个recyclerview或者listview来做为一个父容器，然后再往里面填入多个不同样式的recyclerview,这样就可以实现了，只不过有点不同的是，手机上可以直接滑动，而在TV上却是需要使用焦点来控制界面下滑的，举个列子，布局一由gridLayoutManager来垂直布局，布局二由gridLayoutManager来垂直布局，这样的话当你的焦点时无法从布局一跳到布局二上的，只有当两个布局都是平行布局的时候才可以让焦点跳动，，当然其中还有很多别的布局方式，你都可以尝试一下，，，，讲一下解决办法，，，使用瀑布流就OK了，，两个瀑布流的垂直布局是不会阻拦焦点的。。对了，关于子recyclerview的高度可以设定为自动获取的，根据item的高度去设置。
2.如何自动加载，完成分页
需求:一个页面每次加载20条数据，当焦点滚动到底部后，自动加载下一页的数据
在TV里面下拉刷新显然是不现实的，所以我在就使用自动加载来完成，，首先我们需要去判断焦点的位置在哪里，是否滚动到了底部，当页面加载完数据后，焦点是否在当前页面上
public abstract class EndlessRecyclerOnScrollListener extends
        RecyclerView.OnScrollListener {
    public static String TAG = EndlessRecyclerOnScrollListener.class
            .getSimpleName();


    private int previousTotal = 0;
    private boolean loading = true;
    int lastCompletelyVisiableItemPosition, visibleItemCount, totalItemCount, pastVisiblesItems;


    private int currentPage = 1;
    private GridLayoutManager mGridLayoutManager;

    public EndlessRecyclerOnScrollListener(
            GridLayoutManager mGridLayoutManager,) {
        this.mGridLayoutManager = mGridLayoutManager;
     
    }


    @Override
    public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
        super.onScrolled(recyclerView, dx, dy);


        visibleItemCount = recyclerView.getChildCount();
        totalItemCount = mGridLayoutManager.getItemCount();


        Log.v("wuxiaotol", totalItemCount + "");    //总数
        Log.v("wuxiaochi", mGridLayoutManager.getChildCount() + ""); //可见的item数量
        Log.v("wuxiaolast", mGridLayoutManager.findLastVisibleItemPosition() + ""); //最后一个




        //得到当前显示的最后一个item的view
        View lastChildView = mGridLayoutManager.getChildAt(visibleItemCount - 1);
        //得到lastChildView的bottom坐标值
        if (lastChildView != null) {
            int lastChildBottom = lastChildView.getBottom();
            //得到Recyclerview的底部坐标减去底部padding值，也就是显示内容最底部的坐标
            int recyclerBottom = recyclerView.getBottom() - recyclerView.getPaddingBottom();
            //通过这个lastChildView得到这个view当前的position值
            int lastPosition = mGridLayoutManager.getPosition(lastChildView);
            //判断lastChildView的bottom值跟recyclerBottom
            //判断lastPosition是不是最后一个position
            //如果两个条件都满足则说明是真正的滑动到了底部
            if (lastChildBottom == recyclerBottom && lastPosition == totalItemCount - 1&&totalItemCount>=20) {
                Log.v("wuxiao_last", "滑动到最后了");
                Log.v("wuxiao_cur", currentPage + "");
                currentPage++;
                onLoadMore(currentPage);
                loading = true;
            }
        }
    }


    public abstract void onLoadMore(int currentPage);
}

上面的代码是一个自定义的布局布局管理器，在这个布局管理器里面主要做了这么几个操作，首先获取当前页面显示的最后一个itemView的位置，然后再获取recyclerView的底部，判断焦点是否滑动到了底部，如果滑动到底部后，当前页面加1并传给activity进行网络操作，，如果你在加载完数据后发现焦点不见了，没关系，先找到焦点去了哪里，然后再重新定义焦点的位置，，焦点不会失踪，如果你看不到，只能说明焦点在你看不到的地方，，

