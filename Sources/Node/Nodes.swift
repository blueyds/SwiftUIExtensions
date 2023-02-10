
public class Node<Value>{
    public typealias NodeType = Node<Value>
    public var data: Value
    private(set) public var parent: NodeType? = nil
    private(set) public var children: [NodeType] = []

    public init(_ value: Value){
        self.data = value
    }
}
extension Node where Value: Equatable{
    public static func == (lhs: NodeType, rhs: NodeType) -> Bool {
        return lhs.data == rhs.data
    }
    public func removeChild(node: NodeType){
        children.removeAll(where: {$0 == node})
    }
}
extension Node where Value: Identifiable{
    public var id: Value.ID {
        data.id
    }
    public func removeChild(withID: Value.ID){
        self[withID]?.parent = nil
        children.removeAll(where: {$0.id == withID})
    }
    public subscript(_ id: Value.ID)-> NodeType?{
        var result: NodeType? = nil
        result = children.first(where: {$0.id == id})
        if result == nil {
            result = descendents.first(where: {$0.id == id})  
        }
        return result
    }
    public func move(under node: NodeType){
        if parent != nil {
            parent!.removeChild(withID: self.id)
        }
        node.add(child: self)
    }
}

extension Node{
    public func add(child: NodeType){
        child.set(parent: self)
        children.append(child)
    }
    
    internal func set(parent: NodeType){
        self.parent = parent
    }
    
    
    public var descendents: [NodeType] {
        var result: [NodeType] = []
        children.forEach(){
            result.append($0)
            result.append(contentsOf: $0.descendents)
        }
        return result
    }
    public var ancestors: [NodeType]{
        var result: [NodeType] = []
        if parent != nil {
            result.append(parent!)
            result.append(contentsOf: parent!.ancestors)
        }
        return result
    }
    
}
