//
//  PostsViewController.swift
//  VelogOnMobile
//
//  Created by 장석우 on 2023/06/02.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class HomeViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let rootView = HomeView()
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    let updateHomeEvent = PublishRelay<Void>()
    
    private var currentIndex: Int = 1 {
        didSet {
            changeViewController(before: oldValue, after: currentIndex)
        }
    }
    
    //MARK: - PageViewController
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return viewController
    }()
    
    private var dataSourceViewController: [UIViewController] = []
    
    //MARK: - UI Components
    
    //MARK: - Life Cycle
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        delegate()
        bindUI()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = rootView
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(rootView.menuBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Custom Method
    
    private func delegate() {
        rootView.menuBar.delegate = self
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    private func bindUI() {
        rootView.searchButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.moveToSearchPostViewController()
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        
        let input = HomeViewModel.Input(
            viewDidLoadEvent: rx.viewDidLoad.asObservable(),
            updateHomeEvent: updateHomeEvent.asObservable()
        )
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.tags
            .subscribe(with: self, onNext: { owner, tags in
                owner.rootView.menuBar.dataBind(tags: tags)
                owner.setPageViewController(tags: tags)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Custom Method
    
    private func setPageViewController(tags: [String]) {
        let factory = KeywordPostsVCFactory()
        
        dataSourceViewController = [
            UIViewController(),
            PostsViewController(viewModel: .init(viewType: .trend), isNavigationBarHidden: true),
            PostsViewController(viewModel: .init(viewType: .follow), isNavigationBarHidden: true)
        ]
        
        for tag in tags {
            let vc = factory.create(tag: tag, isNavigationBarHidden: true)
            dataSourceViewController.append(vc)
        }
        
        currentIndex = 1
    }
    
    private func changeViewController(before beforeIndex: Int, after newIndex: Int) {
        
        let direction: UIPageViewController.NavigationDirection = beforeIndex < newIndex ? .forward : .reverse
        
        
        pageViewController.setViewControllers([dataSourceViewController[currentIndex]],
                                              direction: direction,
                                              animated: true,
                                              completion: nil)
        rootView.menuBar.selectedItem = newIndex
    }
    
    //MARK: - Action Method
    
    @objc
    private func moveToSearchPostViewController() {
        let postSearchViewModel = PostSearchViewModel()
        let searchPostViewController = PostSearchViewController(viewModel: postSearchViewModel)
        navigationController?.pushViewController(searchPostViewController, animated: true)
    }
}

extension HomeViewController: HomeMenuBarDelegate {
    func menuBar(didSelectItemAt item: Int) {
        if item == 0 {
            let tagSearchVC = TagSearchViewController(viewModel: TagSearchViewModel(service: DefaultTagService.shared))
            navigationController?.pushViewController(tagSearchVC, animated: true)
            return
        }
        currentIndex = item
    }
}

//MARK: - UIPageViewControllerDataSource

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = dataSourceViewController.firstIndex(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        guard nextIndex != dataSourceViewController.count else { return nil }
        return dataSourceViewController[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = dataSourceViewController.firstIndex(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 1 else { return nil }
        return dataSourceViewController[previousIndex]
    }
}

//MARK: - UIPageViewControllerDelegate

extension HomeViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = dataSourceViewController.firstIndex(of: currentVC) else { return }
        self.currentIndex = currentIndex
    }
}

