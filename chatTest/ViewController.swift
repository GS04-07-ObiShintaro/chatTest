import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ViewController: JSQMessagesViewController {
   var messages = [JSQMessage]()
   var mesDate : [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        senderDisplayName = "A"
        senderId = "Dummy"
        
//        let ref = FIRDatabase.database().reference()
//        ref.observe(.value, with: { snapshot in
//            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
//                return
//            }
//            guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
//                return
//            }
//            
//            self.messages = posts.values.map { dic in
//                let senderId = dic["senderId"] ?? ""
//                let text = dic["text"] ?? ""
//                let displayName = dic["displayName"] ?? ""
//                return JSQMessage(senderId: senderId,  displayName: displayName, text: text)
//            }
//            
//            self.collectionView.reloadData()
//        })
        
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT::: .childAddedイベントが発生しました。")
            guard let dic = snapshot.value as? Dictionary<String,String> else {
                return
            }
            let senderId = dic["senderId"]
            let text = dic["text"]
            let displayName = dic["displayName"]
            let mes = JSQMessage(senderId: senderId, displayName: displayName,  text: text)
            //let mes2 = JSQMessage(senderId: senderId, senderDisplayName: displayName, date: Date(), text: text)
            self.messages.append(mes!)
            self.mesDate.append(dic["date"]!)
            self.collectionView.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!{
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(
                with: UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(
                with: UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!{
        return JSQMessagesAvatarImageFactory.avatarImage(
            withUserInitials: messages[indexPath.row].senderDisplayName,
            backgroundColor: UIColor.lightGray, textColor: UIColor.white,
            font: UIFont.systemFont(ofSize: 10), diameter: 30)
    }
    
    //アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages.count)
    }
    

//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString!{
//        //print(":::\(indexPath.row)")
//        print(":::1")
//        return test2
//    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
        let Date = mesDate[indexPath.row]
        return NSAttributedString(string: Date!)

    }
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
//         print(":::3")
//        return test2
//    }
    

    
    let testCG = CGFloat(20.0)
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat{
        return testCG
    }
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat{
//        print(":::9")
//        return testCG
//    }
    
//↓ボトム
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat{
//        return testCG
//    }
    
    
    
    //送信ボタンを押したとき,データベースにコメントを保存
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        inputToolbar.contentView.textView.text = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        let dateString:String = formatter.string(from: date)
        let mes = ["senderId": senderId!, "text": text!, "displayName": senderDisplayName!, "date": dateString]
        let ref = FIRDatabase.database().reference()
        ref.child("messages").childByAutoId().setValue(mes)
    }
}
