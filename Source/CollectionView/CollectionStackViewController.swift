//
//  CollectionStackViewController.swift
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

// MARK: CollectionStackViewController

protocol CollectionStackViewControllerDelegate: class {
  func controllerDidSelected(index: Int)
}


class CollectionStackViewController: UICollectionViewController {
  private var screens: [UIImage]
  private let overlay: Float
  
  weak var delegate: CollectionStackViewControllerDelegate?
  
  init(images: [UIImage],
    delegate: CollectionStackViewControllerDelegate?,
    overlay: Float,
    scaleRatio: Float,
    scaleValue: Float,
    bgColor: UIColor,
    decelerationRate:CGFloat) {
      
      self.screens  = images
      self.delegate = delegate
      self.overlay  = overlay
        
      let layout = CollectionViewStackFlowLayout(itemsCount: images.count, overlay: overlay, scaleRatio: scaleRatio, scale:scaleValue)
      super.init(collectionViewLayout: layout)
      
      if let collectionView = self.collectionView {
        collectionView.backgroundColor  = bgColor
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: decelerationRate)
      }
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    configureCollectionView()
    collectionView.scrollToItem(at: IndexPath(item: (screens.count - 1), section: 0), at: .left, animated: true)// move to end
  }
  
    override func viewDidAppear(_ animated: Bool) {
    
    guard let collectionViewLayout = self.collectionViewLayout as? CollectionViewStackFlowLayout else {
      fatalError("wrong collection layout")
    }
    
    collectionViewLayout.openAnimating = true
    collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true) // open animation
  }
}

// MARK: configure

extension CollectionStackViewController {
  
  private func configureCollectionView() {
    guard let collectionViewLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
      fatalError("wrong collection layout")
    }
    
    collectionViewLayout.scrollDirection = .horizontal
    collectionView?.showsHorizontalScrollIndicator = false
    collectionView?.register(CollectionViewStackCell.self, forCellWithReuseIdentifier: "CollectionViewStackCell")
  }

}

// MARK: CollectionViewDataSource

extension CollectionStackViewController {
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return screens.count
  }
  
//  override func collectionView(collectionView: UICollectionView,
//                         willDisplayCell cell: UICollectionViewCell,
//                  forItemAtIndexPath indexPath: NSIndexPath) {
//
//
//    }
//  }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CollectionViewStackCell {
            cell.imageView?.image = screens[indexPath.row]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewStackCell",
                                                      for: indexPath)
        return cell
    }
  
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.controllerDidSelected(index: indexPath.row)
    
    guard let currentCell = collectionView.cellForItem(at: indexPath as IndexPath) else {
      return
    }

    // move cells
    UIView.animate(withDuration: 0.3, delay: 0, options:.curveEaseIn,
    animations: { () -> Void in
      for  cell in self.collectionView!.visibleCells where cell != currentCell {
        let row = self.collectionView?.indexPath(for: cell)?.row
        let xPosition = row! < indexPath.row ? cell.center.x - self.view.bounds.size.width * 2
                                            : cell.center.x + self.view.bounds.size.width * 2
        
        cell.center = CGPoint(x: xPosition, y: cell.center.y)
      }
      }, completion: nil)
    
    // move to center current cell
    UIView.animate(withDuration: 0.2, delay: 0.2, options:.curveEaseOut,
      animations: { () -> Void in
        let offset = collectionView.contentOffset.x - (self.view.bounds.size.width - collectionView.bounds.size.width * CGFloat(self.overlay)) * CGFloat(indexPath.row)
        currentCell.center = CGPoint(x: (currentCell.center.x + offset), y: currentCell.center.y)
      }, completion: nil)
  
    // scale current cell
    UIView.animate(withDuration: 0.2, delay: 0.6, options:.curveEaseOut, animations: { () -> Void in
        let scale = CGAffineTransform(scaleX: 1, y: 1)
      currentCell.transform = scale
      currentCell.alpha = 1
      
    }) { (success) -> Void in
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
        }
    }
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CollectionStackViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return view.bounds.size
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
    return -collectionView.bounds.size.width * CGFloat(overlay)
  }
}


// MARK: Additional helpers

extension CollectionStackViewController {
  
    private func scrolltoIndex(index: Int, animated: Bool , position: UICollectionView.ScrollPosition) {
        let indexPath = NSIndexPath(item: index, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: position, animated: animated)
  }
}
