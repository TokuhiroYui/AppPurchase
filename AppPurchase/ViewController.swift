//
//  ViewController.swift
//  AppPurchase
//
//  Created by 徳弘佑衣 on 2015/06/20.
//  Copyright (c) 2015年 徳弘佑衣. All rights reserved.
//

import UIKit

//StoreKitをimport
import StoreKit

//delegateを設定
//SKProductsRequestDelegate:アイテムの情報の取得処理をするためのプロトコル
//SKPaymentTransactionObserver:アイテムの購入を処理するためのプロトコル
class ViewController: UIViewController,SKProductsRequestDelegate, SKPaymentTransactionObserver{

    //初期設定
    override func viewDidLoad() {
        super.viewDidLoad()
        if !SKPaymentQueue.canMakePayments() {
            // エラーメッセージを表示する
            let alertController = UIAlertController(title: "課金設定チェック",
                message: "アプリ内課金の使用が制限されています。",
                preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "閉じる", style: .Default, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "applicationDidEnterBackground",
            name: UIApplicationDidEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: "applicationWillEnterForeground",
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    //ボタンを押したときの処理
    @IBAction func purchaseApp(sender: AnyObject) {
        //iTunesConnectで設定した IDをセット
        let set = NSSet(objects: "com.deco.xxxxxxxx")
        let productRequest = SKProductsRequest(productIdentifiers: set as Set<NSObject>)
        productRequest.delegate = self
        //start()メソッドで、開始
        productRequest.start()
    }
    //情報を受け取って購入処理を開始する
    func productsRequest(request: SKProductsRequest!,
        didReceiveResponse response: SKProductsResponse!) {
            if response.invalidProductIdentifiers.count > 0 {
                let alertController = UIAlertController(title: "課金アイテムチェック",
                    message: "アイテムIDが不正です。",
                    preferredStyle: .Alert)
                let action = UIAlertAction(title: "閉じる", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            for product in response.products {
                let payment = SKPayment(product: product as! SKProduct)
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }
    }
    
    //アイテム購入処理
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case .Purchasing:
                println("処理中...")
            case .Purchased:
                //購入成功
                //アイテムの付与を行う
                //レシートの発行
                let url = NSBundle.mainBundle().appStoreReceiptURL
                let data = NSData(contentsOfURL: url!)!
                let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
                println(base64)
                queue.finishTransaction(transaction)
            case .Failed:
                println(transaction.error.localizedDescription)
            default:
                println()
            }
        }
    }
    
    //購入処理の終了
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as! [SKPaymentTransaction] {
            if transaction.transactionState == .Purchased {

            }
        }
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

