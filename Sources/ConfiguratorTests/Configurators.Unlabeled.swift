import Configurator
import Testing

extension Configurators {
    struct Unlabeled {
        var x: Int

        @Configurator init<E>(
            x: Int,
            _ body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }
}
extension Configurators {
    @Test static func UnlabeledClosure() {
        let unlabeled: Unlabeled = .init(x: 11)
        #expect(unlabeled.x == 11)
    }
}
