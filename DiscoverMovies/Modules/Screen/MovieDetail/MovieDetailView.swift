import SwiftUI
import WebKit

struct MovieDetailView: View {
    @StateObject private var presenter: MovieDetailPresenter

    init(presenter: MovieDetailPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                if let item = presenter.movieItem {
                    movieInfo(item)
                }

                Text("Trailer")
                    .font(.system(size: 18, weight: .bold))

                if let url = presenter.trailerURL {
                    TrailerWebView(url: url)
                        .frame(height: 210)
                        .background(Color(.secondarySystemBackground))
                } else {
                    ZStack {
                        Color(.secondarySystemBackground)
                        if presenter.trailerUnavailable {
                            Text("Trailer unavailable")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 210)
                }

                Text("Reviews")
                    .font(.system(size: 18, weight: .bold))

                if let message = presenter.reviewStateMessage {
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }

                ForEach(presenter.reviews.indices, id: \.self) { index in
                    VStack(spacing: 0) {
                        reviewRow(presenter.reviews[index])
                        Divider()
                    }
                    .onAppear {
                        presenter.didScrollToReview(at: index)
                    }
                }

                if presenter.isLoadingReviews {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Movie Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task {
            presenter.viewDidLoad()
        }
    }

    private func movieInfo(_ item: MovieDetailDisplayItem) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: item.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .empty, .failure:
                    Image(systemName: "photo")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.secondary)
                @unknown default:
                    Image(systemName: "photo")
                }
            }
            .frame(width: 120, height: 180)
            .background(Color(.secondarySystemBackground))
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 24, weight: .bold))
                Text(item.ratingText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(item.overviewText)
                    .font(.system(size: 15))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func reviewRow(_ item: ReviewDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.author)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
            Text(item.content)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineLimit(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

private struct TrailerWebView: UIViewRepresentable {
    let url: URL

    final class Coordinator {
        var loadedURL: URL?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.load(URLRequest(url: url))
        context.coordinator.loadedURL = url
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.loadedURL != url {
            webView.load(URLRequest(url: url))
            context.coordinator.loadedURL = url
        }
    }
}
