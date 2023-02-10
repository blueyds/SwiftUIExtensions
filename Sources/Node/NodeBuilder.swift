
// MARK: ResultBuilder
@resultBuilder
public struct NodeBuilder{
    public static func buildBlock<Value>(_ children: Node<Value>...) -> [Node<Value>] {
        children
        }
}

extension Node{
    public convenience init(_ value: Value, @NodeBuilder builder: () -> [NodeType]){
        self.init(value)
        builder().forEach(){
            add(child: $0)
        }
    }
}
