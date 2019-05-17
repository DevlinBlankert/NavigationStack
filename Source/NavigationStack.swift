//
//  NavigationStack.swift
//  NavigationStackDemo
//
// Copyright (c) 26/02/16 Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

// MARK: NavigationStack

public class NavigationStack: UINavigationController {
    
    @IBInspectable var overlay: Float = 0.8
    @IBInspectable var scaleRatio: Float = 14.0
    @IBInspectable var scaleValue: Float = 0.99
    @IBInspectable var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue
    
    @IBInspectable var bgColor: UIColor = .black
    
    private var screens = [UIImage]()
    
    weak public var stackDelegate: UINavigationControllerDelegate? // use this instead delegate
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
    }
}

// MARK: pulbic methods

extension NavigationStack {
    public func showControllers() {
        if screens.count == 0 {
            return
        }
        
        var allScreens = screens
        allScreens.append(view.takeScreenshot())
        let collectioView = CollectionStackViewController(images: allScreens,
                                                          delegate: self,
                                                          overlay: overlay,
                                                          scaleRatio: scaleRatio,
                                                          scaleValue: scaleValue,
                                                          bgColor: bgColor,
                                                          decelerationRate: decelerationRate)
        
        present(collectioView, animated: false, completion: nil)
    }
}


// MARK: Additional helpers

extension NavigationStack {
    
    private func popToIndex(index: Int, animated: Bool) {
        let viewController = viewControllers[index]
        popToViewController(viewController, animated: animated)
    }
}


// MARK: UINavigationControllerDelegate

extension NavigationStack: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {
        stackDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
       // stackDelegate?.navigationController?(navigationController, willShowViewController: viewController, animated: animated)
        
        if navigationController.viewControllers.count > screens.count + 1 {
            screens.append(view.takeScreenshot())
        } else
            if navigationController.viewControllers.count == screens.count && screens.count > 0 {
                screens.removeLast()
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        stackDelegate?.navigationController?(navigationController, didShow: navigationController, animated: animated)
    }
    
    //  ???
    //  public func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
    //    return stackDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController)
    //  }
    
    //  ???
    //  optional public func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation
    //
    
//    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return stackDelegate?.intersa
//    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return stackDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
    
}

extension NavigationStack: CollectionStackViewControllerDelegate {
    func controllerDidSelected(index: Int) {
        popToIndex(index: index, animated: false)
        screens.removeSubrange(index..<screens.count)
    }
}

// MARK: UIView

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
