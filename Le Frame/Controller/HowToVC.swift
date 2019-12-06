//
//  HowToVC.swift
//  Le Frame
//
//  Created by Saar Botzer on 30/11/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit

class HowToVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVC(viewController: "screenOne"),
                self.newVC(viewController: "screenTwo"),
                self.newVC(viewController: "screenThree"),
                self.newVC(viewController: "screenFour"),
                self.newVC(viewController: "screenFive"),
                self.newVC(viewController: "screenSix")
        ]
    }()
    
    var pageControl = UIPageControl()
    var currentIndex = 0
    
    var gridView = UIStackView()
    let defaults = UserDefaults.standard
    
    var originalTransform: CGAffineTransform?
    
    let royalFrameGrid = [
        ["h13", "c12",          "d12",          "s13"],
        ["s11", "green_card",   "green_card",   "h11"],
        ["c11", "green_card",   "green_card",   "d11"],
        ["d13", "s12",          "h12",          "c13"]
            ]
    
    let removalGrid = [
        ["s13", "s10",   "h8",  "d13"],
        ["c3",  "c3",    "d5",  "h8"],
        ["d1",  "d6",    "h1",  "c11"],
        ["h3",  "s9",    "s12", "c1"]
    ]
    
    let blockedGrid = [
        ["s13",         "green_card",   "h8",   "d13"],
        ["c3",          "c3",           "d5",   "h8"],
        ["green_card",  "d6",           "h1",   "c11"],
        ["h3",          "green_card",   "s12",  "c1"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        

//        addSkipButton()

        addGrid(with: royalFrameGrid)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        configurePageControl()
        
        for subview in self.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break;
            }
        }
    }
    
    func addTopLabel() {
        
        // TODO: Add label to view
        
        let label = UILabel()
        label.text = "How to play?"
        label.font = UIFont(name: "System", size: 20)
        label.textColor = .white
        
        
        view.addSubview(label)
        
    }
    
    func getToShowOnboarding() -> Bool {
        let onboadringShown = defaults.bool(forKey: "onboadringShown")
        
        return !onboadringShown
    }
    
    func removeSkipButton() {
        for subview in view.subviews {
            if subview.tag == 10 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func addSkipButton() {
        
        let skipButtonWidth: CGFloat = 50
        let skipButtonHeight: CGFloat = 30
        let x = UIScreen.main.bounds.maxX - skipButtonWidth * 1.5
        let y = UIScreen.main.bounds.maxY - 150
        
        
        let skipButton = UIButton()
        skipButton.titleLabel?.textColor = UIColor.white
        skipButton.frame = CGRect(x: x, y: y, width: skipButtonWidth, height: skipButtonHeight)
        skipButton.isHidden = false
//        skipButton.backgroundColor = .blue
        skipButton.setTitle("Skip", for: .normal)
        
        skipButton.addTarget(self, action: #selector(goToGame), for: .touchUpInside)
        
        skipButton.tag = 10
        
        self.view.addSubview(skipButton)
    }
    
    @objc func goToGame() {
        performSegue(withIdentifier: "goToGame", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func newVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    // MARK: - PageViewController Functions
    func configurePageControl() {
        
        let pageControlSize = pageControl.size(forNumberOfPages: orderedViewControllers.count)
        
        let pageControlWidth = pageControlSize.width + 20
        let pageControlHeight = pageControlSize.height - 10
        let x = UIScreen.main.bounds.maxX / 2 - pageControlWidth / 2
        let y = UIScreen.main.bounds.maxY - 150
        
        pageControl = UIPageControl(frame: CGRect(x: x, y: y, width: pageControlWidth, height: pageControlHeight))
        
        pageControl.layer.cornerRadius = 8
        
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
        pageControl.tintColor = .black
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .touchUpInside)
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            return
        }
        
        let pageContentViewController = pageViewController.viewControllers![0]
        
        let index = orderedViewControllers.firstIndex(of: pageViewController.viewControllers![0])
        getGridForScreen(atIndex: index ?? 0)
        currentIndex = index ?? 0
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
                
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let selectedPage = sender.currentPage
        
        var direction = UIPageViewController.NavigationDirection.forward

        if selectedPage == orderedViewControllers.count - 1 {
            direction = .reverse
        }
        
        self.setViewControllers([orderedViewControllers[selectedPage]],
            direction: direction,
            animated: true,
            completion: nil)
        getGridForScreen(atIndex: selectedPage)
    }
    
    
    // MARK: - ScrollView Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (pageControl.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
        } else if (pageControl.currentPage == orderedViewControllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (pageControl.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
        } else if (pageControl.currentPage == orderedViewControllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }
    
    // MARK: - Grid Functions
    
    func addGrid(with gridNames: [[String]]) {
        
        let cardWidth: CGFloat = 50
        let cardHeight: CGFloat = 75
        let horizontalSpace: CGFloat = 10.0
        let verticalSpace: CGFloat = 10.0
        
        let grid = UIStackView()
        grid.axis = .vertical
        grid.distribution = .equalSpacing
        grid.alignment = .center
        
        let gridHeight = cardHeight * 4 + 3 * verticalSpace
        let gridWidth = cardWidth * 4 + 3 * horizontalSpace
        let gridX = (self.view.frame.width - gridWidth) / 2
        let gridY: CGFloat = 100
        
        grid.frame = CGRect(x: gridX, y: gridY, width: gridWidth, height: gridHeight)
        
        for i in 0...3 {
            let gridRowStackView = UIStackView()
            gridRowStackView.axis = .horizontal
            gridRowStackView.distribution = .equalSpacing
            gridRowStackView.alignment = .center
            gridRowStackView.spacing = horizontalSpace
            
            for j in 0...3 {
                let imageName = "\(gridNames[i][j]).jpg"
                let imageView = UIImageView()
                imageView.image = UIImage(named: imageName)
                imageView.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
                imageView.tag = j
                addShadow(for: imageView)
                originalTransform = imageView.transform
            
                gridRowStackView.addArrangedSubview(imageView)
                
            }
            gridRowStackView.tag = i
            grid.addArrangedSubview(gridRowStackView)
        }
        
        grid.tag = 5
        
        self.gridView = grid
        self.view.addSubview(gridView)
    }
    
    func getGridForScreen(atIndex screenIndex: Int) {
        currentIndex = screenIndex
        switch screenIndex {
        case 0:
            highlightRank(rank: nil)
        case 1: // Kings
            highlightRank(rank: .king)
        case 2: // Queens
            highlightRank(rank: .queen)
        case 3: // Jacks
            removeGrid()
            addGrid(with: royalFrameGrid)
            highlightRank(rank: .jack)
//            flipCards(to: royalFrameGrid)
        case 4:
            removeGrid()
            addGrid(with: removalGrid)
            highlightRank(rank: nil)
//            flipCards(to: removalGrid)
            removalAnimation()
        case 5:
            removeGrid()
            addGrid(with: blockedGrid)
            highlightRank(rank: nil)
//            flipCards(to: blockedGrid)
        default:
            highlightRank(rank: nil)
        }
    }
    
    func removeGrid() {
        self.gridView = UIStackView()
                
        for subview in view.subviews {
            if subview.tag == 5 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func flipCards(to gridArrangement: [[String]]) {
        for row in gridView.arrangedSubviews as! [UIStackView] {
            let j = row.tag
            for card in row.arrangedSubviews as! [UIImageView] {
                let i = card.tag
                let wantedImage = "\(gridArrangement[j][i]).jpg"
                flipCard(card: card, flipToCardNamed: wantedImage)
            }
        }
    }
    
    func flipCard(card: UIImageView, flipToCardNamed: String) {
        card.image = UIImage(named: flipToCardNamed)
    }
    
    func removalAnimation() {
        // TODO: Make the animation reset every time switching to this page
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.highlightPairs(at: [IndexPath(row: 1, section: 0)], withDelay: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.highlightPairs(at: [], withDelay: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.removeCard(at: IndexPath(row: 1, section: 0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5) {
            self.highlightPairs(at: [IndexPath(row: 0, section: 2), IndexPath(row: 1, section: 3)], withDelay: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.highlightPairs(at: [], withDelay: 0)
        }
        
//        highlightPairs(at: [], withDelay: 5)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.removeCard(at: IndexPath(row: 0, section: 2))
            self.removeCard(at: IndexPath(row: 1, section: 3))
        }
        
    }
    
    func removeCard(at indexPath: IndexPath) {
        if currentIndex != 4 {
            return
        }
        
        
        for row in gridView.arrangedSubviews as! [UIStackView] {
            let j = row.tag
            for card in row.arrangedSubviews as! [UIImageView] {
                let i = card.tag
                if IndexPath(row: i, section: j) == indexPath {
                    card.image = UIImage(named: "green_card.jpg")
                }
            }
        }
    }
    
    func highlightPairs(at indexes: [IndexPath], withDelay delay: TimeInterval) {
        for row in gridView.arrangedSubviews as! [UIStackView] {
            let j = row.tag
            for card in row.arrangedSubviews as! [UIImageView] {
                let i = card.tag
                let indexPath = IndexPath(row: i, section: j)
                var highlight = true
                let transformBy: CGFloat = 1.15
                let scaledTranfsorm = originalTransform!.scaledBy(x: transformBy, y: transformBy)
                var transform = scaledTranfsorm
                                
                if indexes.contains(indexPath) {
                    transform = scaledTranfsorm
                } else {
                    transform = self.originalTransform!
                    highlight = false
                }
                
                let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                    if self.currentIndex != 4 {
                        return
                    }
                    if self.currentIndex == 4 {
                        card.transform = transform
                    }
                    if highlight {
                        card.layer.shadowRadius = 4
                    } else {
                        card.layer.shadowRadius = 1
                    }
                }
                
                animator.startAnimation(afterDelay: delay)
//                animator.startAnimation()
            }
        }
    }

    func highlightRank(rank: CardRank?) {
        for row in gridView.arrangedSubviews as! [UIStackView] {
            let j = row.tag
            for cell in row.arrangedSubviews as! [UIImageView] {
                let i = cell.tag
                                
                let transformBy: CGFloat = 1.15
                let scaledTranfsorm = originalTransform!.scaledBy(x: transformBy, y: transformBy)
                var transform = scaledTranfsorm
                
                let indexPath = IndexPath(row: i, section: j)
                
                let allowedRanks = Utilities.getAllowedRanksByPosition(indexPath: indexPath)
                
                var highlight = true
                
                if (allowedRanks == .kings && rank == .king) ||
                    (allowedRanks == .queens && rank == .queen) ||
                    (allowedRanks == .jacks && rank == .jack) {
                    transform = scaledTranfsorm
                } else {
                    transform = self.originalTransform!
                    highlight = false
                }
                
                let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                    cell.transform = transform
                    if highlight {
                        cell.layer.shadowRadius = 4
                    } else {
                        cell.layer.shadowRadius = 1
                    }
                }
                animator.startAnimation()
                
            }
        }
    }
    
    func addShadow(for view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 1

    }
}

