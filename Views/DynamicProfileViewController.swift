import UIKit

class DynamicProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ProfileViewModel
    private var scrollView: UIScrollView!
    private var contentView: UIStackView!
    private var nextButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Initialization
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ProfileViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.loadProfiles()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        // Scroll View
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content Stack View
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Loading Indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        // Next Button
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next Profile", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        if viewModel.isLoading {
            loadingIndicator.startAnimating()
            contentView.isHidden = true
            nextButton.isEnabled = false
            return
        }
        
        loadingIndicator.stopAnimating()
        contentView.isHidden = false
        
        // Clear existing views
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add views for ordered fields
        let fields = viewModel.orderedFields
        if fields.isEmpty {
            showEmptyState()
        } else {
            for fieldViewModel in fields {
                if let view = createView(for: fieldViewModel) {
                    contentView.addArrangedSubview(view)
                }
            }
        }
        
        // Update button state
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
        nextButton.isEnabled = viewModel.canNavigateToNext
        nextButton.backgroundColor = viewModel.canNavigateToNext ? .systemBlue : .systemGray
    }
    
    // MARK: - View Creation
    private func createView(for fieldViewModel: ProfileFieldViewModel) -> UIView? {
        switch fieldViewModel.type {
        case .photo:
            return createPhotoView(photos: fieldViewModel.photos ?? [])
        case .aboutMe:
            guard let text = fieldViewModel.value else { return nil }
            return createTextView(title: fieldViewModel.title, text: text)
        case .name:
            return createLabelView(title: fieldViewModel.title, text: fieldViewModel.value ?? "", style: .title1)
        case .age, .school, .job, .location:
            guard let text = fieldViewModel.value else { return nil }
            return createLabelView(title: fieldViewModel.title, text: text, style: .body)
        }
    }
    
    private func createPhotoView(photos: [String]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load image from URL
        if let urlString = photos.first, let url = URL(string: urlString) {
            loadImage(from: url, into: imageView)
        } else {
            imageView.image = UIImage(systemName: "person.fill")
            imageView.tintColor = .systemGray3
        }
        
        containerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        return containerView
    }
    
    private func createLabelView(title: String, text: String, style: UIFont.TextStyle) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .preferredFont(forTextStyle: style)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createTextView(title: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .systemGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textView = UITextView()
        textView.text = text
        textView.font = .preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        viewModel.moveToNextProfile()
    }
    
    // MARK: - Helpers
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(systemName: "person.fill")
                    imageView.tintColor = .systemGray3
                }
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
    
    private func showEmptyState() {
        let label = UILabel()
        label.text = "No profiles available"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addArrangedSubview(label)
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load profile data. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadProfiles()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showEndOfListAlert() {
        let alert = UIAlertController(
            title: "All Profiles Viewed",
            message: "You've seen all available profiles.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Start Over", style: .default) { [weak self] _ in
            self?.viewModel.resetToFirstProfile()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - ProfileViewModelDelegate
extension DynamicProfileViewController: ProfileViewModelDelegate {
    func profileViewModelDidUpdateState(_ viewModel: ProfileViewModel) {
        updateUI()
    }
    
    func profileViewModel(_ viewModel: ProfileViewModel, didEncounterError error: Error) {
        showErrorAlert(error: error)
    }
    
    func profileViewModelDidReachEnd(_ viewModel: ProfileViewModel) {
        showEndOfListAlert()
    }
}
