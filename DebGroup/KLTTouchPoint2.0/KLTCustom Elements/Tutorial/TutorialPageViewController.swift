//
//  TutorialPageViewController.swift
//  KLTOpenTab
//
//  Created by Sameer Siddiqui on 9/20/17.
//  Copyright © 2017 Raul Silva. All rights reserved.
//

import UIKit

protocol TutorialDelegate {
    func tutorialDidScroll(to index: Int)
}

class TutorialPageViewController: UIPageViewController {

    lazy var orderedViewControllers: [TutorialBaseViewController] = {
        return [TutorialBaseViewController.create(at: 0),
                TutorialBaseViewController.create(at: 1),
                TutorialBaseViewController.create(at: 2),
                TutorialBaseViewController.create(at: 3),
                TutorialBaseViewController.create(at: 4),
                TutorialBaseViewController.create(at: 5),
                TutorialBaseViewController.create(at: 6),
                TutorialBaseViewController.create(at: 7),
                TutorialBaseViewController.create(at: 8),
                TutorialBaseViewController.create(at: 9),
                TutorialBaseViewController.create(at: 10),
                TutorialBaseViewController.create(at: 11),
                TutorialBaseViewController.create(at: 12),
                TutorialBaseViewController.create(at: 13),
                TutorialBaseViewController.create(at: 14),
                TutorialBaseViewController.create(at: 15),
                TutorialBaseViewController.create(at: 16),
                TutorialBaseViewController.create(at: 17),
                TutorialBaseViewController.create(at: 18)]
    }()
    
    var countLabel: UILabel!
    var bottomButton: UIButton!

    
    public class func create() -> TutorialPageViewController {
        let storyboard = UIStoryboard.init(name: "KLTMain", bundle: frameworkBundle)
        let main = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! TutorialPageViewController
        return main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        
        bottomButton = UIButton.init()
        bottomButton.backgroundColor = UIColor.init(red: 19/255, green: 87/255, blue: 159/255, alpha: 1.0)
        bottomButton.setAttributedTitle(NSAttributedString.init(string: "SKIP", attributes: buttonTextAttributes), for: .normal)
        bottomButton.addTarget(self, action: #selector(pressedBottomButton), for: .touchUpInside)
        bottomButton.tintColor = .white
        self.view.addSubview(bottomButton)

        bottomButton.translatesAutoresizingMaskIntoConstraints = false

        bottomButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bottomButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        bottomButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        bottomButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        
        countLabel = UILabel.init()
        countLabel.attributedText = NSAttributedString.init(string: "1/\(orderedViewControllers.count)", attributes: filterTextAttributes)
        self.view.addSubview(countLabel)
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        countLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true

        countLabel.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        countLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        
        
        
        
        UserDefaults.standard.set(true, forKey: "didViewTutorial")
    }

    @objc func pressedBottomButton() {
       self.dismiss(animated: true, completion: nil)
    }
    
}

extension TutorialPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
      
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! TutorialBaseViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
//            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! TutorialBaseViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
//            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0] as! TutorialBaseViewController
        countLabel.attributedText = NSAttributedString.init(string: "\(orderedViewControllers.index(of: pageContentViewController)! + 1)/\(orderedViewControllers.count)", attributes: filterTextAttributes)
        if (orderedViewControllers.index(of: pageContentViewController)! + 1) == orderedViewControllers.count {
            bottomButton.setAttributedTitle(NSAttributedString.init(string: "GOT IT!", attributes: buttonTextAttributes), for: .normal)
        }
        else {
            bottomButton.setAttributedTitle(NSAttributedString.init(string: "SKIP", attributes: buttonTextAttributes), for: .normal)
        }
    }

}



