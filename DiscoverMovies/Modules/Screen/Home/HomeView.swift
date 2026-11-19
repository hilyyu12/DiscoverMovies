import SwiftUI

struct HomeView: View {
    @StateObject private var presenter: HomePresenter
    @StateObject private var router: HomeRouter
    @State private var searchText = ""

    init(presenter: HomePresenter, router: HomeRouter) {
        _presenter = StateObject(wrappedValue: presenter)
        _router = StateObject(wrappedValue: router)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                searchField
                ScrollView {
                    LazyVStack(spacing: 0) {
                        genreChips
                        content
                    }
                }
            }
            .background(Color(.systemBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $router.selectedMovie) { movie in
                router.makeDetail(for: movie)
            }
            .task {
                presenter.viewDidLoad()
            }
        }
    }

    private var header: some View {
        ZStack {
            Color(red: 0.11, green: 0.225, blue: 0.449)
            Text("Discover Movies")
                .font(.custom("Futura-Bold", size: 21))
                .foregroundStyle(.white)
            HStack {
                Spacer()
                Image(systemName: "heart")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 70)
    }

    private var searchField: some View {
        TextField("Search Movies..", text: $searchText)
            .font(.system(size: 14))
            .padding(.horizontal, 14)
            .frame(height: 50)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            }
            .padding(.horizontal, 15)
            .frame(height: 70)
            .onChange(of: searchText) { _, newValue in
                presenter.didUpdateSearchText(newValue)
            }
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(presenter.genres.enumerated()), id: \.element.id) { index, genre in
                    Button {
                        presenter.didSelectGenre(at: index)
                    } label: {
                        Text(genre.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(genre.isSelected ? .white : Color.primary)
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .frame(minWidth: 72)
                            .background(genre.isSelected ? Color(red: 0.27, green: 0.19, blue: 0.60) : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(genre.isSelected ? .clear : Color(.systemGray4), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 58)
    }

    @ViewBuilder
    private var content: some View {
        if presenter.isLoadingFirstPage && presenter.movies.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 200)
        } else if let error = presenter.errorMessage, presenter.movies.isEmpty {
            stateView(error)
        } else if let empty = presenter.emptyMessage {
            stateView(empty)
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(presenter.movies.indices, id: \.self) { index in
                    Button {
                        presenter.didSelectMovie(at: index)
                    } label: {
                        posterCard(presenter.movies[index])
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        presenter.didScrollToItem(at: index)
                    }
                }
            }
            .padding(16)

            if presenter.isLoadingNextPage {
                ProgressView()
                    .frame(height: 52)
            }
            if let error = presenter.errorMessage {
                stateView(error)
            }
        }
    }

    private func stateView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if presenter.errorMessage != nil {
                Button("Retry") { presenter.retry() }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding(.horizontal, 16)
    }

    private func posterCard(_ movie: MovieRowDisplayItem) -> some View {
        VStack(alignment: .leading) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.secondary)
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.2))
                @unknown default:
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
