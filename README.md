# DataFlowDemo

### 单向数据流动的函数式编程实践（OC）

说明:Demo启发于Redux，将一个类似于搜索的逻辑，用State和Action，reduce等分开。使得UI等操作集中在一处，更重要的是方便写单元测试。

VC不直接操作数据源，VC通过发出action作用于State，VC成为State的订阅者，State接收到action，通过Reduce函数reduce(state: State,action: Action) -> State 返回一个新的State，并通知订阅者。订阅者根据State的状态决定UI的显示逻辑。

好处：基于State的结构更容易被测试，方便维护。

参考资料：

1.(https://onevcat.com/2017/07/state-based-viewcontroller/)

2.(http://chris.eidhof.nl/post/reducers/)

3.(https://news.realm.io/news/benji-encz-unidirectional-data-flow-swift/)

