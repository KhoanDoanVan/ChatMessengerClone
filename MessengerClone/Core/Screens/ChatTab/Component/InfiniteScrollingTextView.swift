import SwiftUI

struct InfiniteScrollingTextView: View {
    let text: String
    let speed: Double
    let width: CGFloat

    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth: CGFloat = width
            
            HStack(spacing: 0) {
                Text(text)
                    .font(.system(size: 9))
                    .bold()
                    .background(GeometryReader { textGeometry in
                        Color.clear.onAppear {
                            textWidth = textGeometry.size.width
                        }
                    })
                    .offset(x: offset)
                    .onAppear {
                        startScrolling(screenWidth: screenWidth)
                    }
            }
            .frame(width: screenWidth, alignment: .leading)
            .clipped()
        }
        .frame(width: width, height: 10)
    }
    
    private func startScrolling(screenWidth: CGFloat) {
        offset = -textWidth

        withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false)) {
            offset = screenWidth
        }
    }
}

#Preview(body: {
    InfiniteScrollingTextView(text: "This is an infinitely", speed: 5, width: CGFloat(100))
})

