import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ViewController: JSQMessagesViewController {
   var messages = [JSQMessage]()
   var mesMonth : [String?] = []
    var mesDay : [String?] = []
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
        
       //Firebase ovserve
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
            self.mesMonth.append(dic["Month"]!)
            self.mesDay.append(dic["day"]!)
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        
        let date = Date()
        let Mformatter = DateFormatter()
        Mformatter.dateFormat = "MM"
        var MdateString:String = Mformatter.string(from: date)
        let Mstart = MdateString.substring(to: MdateString.index(after: MdateString.startIndex))
        if(Mstart == "0"){
            MdateString = MdateString.substring(from: MdateString.index(after: MdateString.startIndex))
        }
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd"
        var ddateString:String = dformatter.string(from: date)
        let dstart = ddateString.substring(to: ddateString.index(after: ddateString.startIndex))
        if(dstart == "0"){
            ddateString = ddateString.substring(from: ddateString.index(after: ddateString.startIndex))
        }

        if(indexPath.row >= 1)
        {
           if(mesMonth[indexPath.row - 1]! + mesDay[indexPath.row - 1]! == mesMonth[indexPath.row]! + mesDay[indexPath.row]!){
               return nil
           }else{
                   if(mesMonth[indexPath.row]! + mesDay[indexPath.row]! == MdateString + ddateString)
                   {
                    return NSAttributedString(string: "Today")
                   }else
                   {
                    return NSAttributedString(string: mesMonth[indexPath.row]! + "月" + mesDay[indexPath.row]! + "日")
                   }
           }
        }else
        {
            if(mesMonth[indexPath.row]! + mesDay[indexPath.row]! == MdateString + ddateString){
                return NSAttributedString(string: "Today")
            }else{
                return NSAttributedString(string: mesMonth[indexPath.row]! + "月" + mesDay[indexPath.row]! + "日")
            }
        }
    }
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
//         print(":::3")
//        return test2
//    }
    

    
    let testCG = CGFloat(20.0)
    let zeroCG = CGFloat(0.0)
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat{
        
        if(indexPath.row >= 1){
            if(mesMonth[indexPath.row - 1]! + mesDay[indexPath.row - 1]! == mesMonth[indexPath.row]! + mesDay[indexPath.row]!){
                return zeroCG
            }else{
                return testCG
            }
        }else{
            return testCG
        }

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
//        let yformatter = DateFormatter()
//        yformatter.dateFormat = "yyyy年MM月dd日HH時mm分"
//        let ydateString:String = yformatter.string(from: date)
        let yformatter = DateFormatter()
        yformatter.dateFormat = "yyyy"
        let ydateString:String = yformatter.string(from: date)
        
        let Mformatter = DateFormatter()
        Mformatter.dateFormat = "MM"
        var MdateString:String = Mformatter.string(from: date)
        let Mstart = MdateString.substring(to: MdateString.index(after: MdateString.startIndex))
        if(Mstart == "0"){
            MdateString = MdateString.substring(from: MdateString.index(after: MdateString.startIndex))
        }
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd"
        var ddateString:String = dformatter.string(from: date)
        let dstart = ddateString.substring(to: ddateString.index(after: ddateString.startIndex))
        if(dstart == "0"){
            ddateString = ddateString.substring(from: ddateString.index(after: ddateString.startIndex))
        }
        
        let Hformatter = DateFormatter()
        Hformatter.dateFormat = "HH"
        let HdateString:String = Hformatter.string(from: date)
//        let Hstart = HdateString.substring(to: HdateString.index(after: HdateString.startIndex))
//        if(Hstart == "0"){
//            HdateString = "午前" + HdateString.substring(from: HdateString.index(after: HdateString.startIndex))
//        }else if(Int(HdateString)! <= 11){
//                HdateString = "午前" + HdateString
//            }else{
//                let IntHdateString = Int(HdateString)! - 12
//                HdateString = "午後" + String(IntHdateString)
//            }
        
        let mformatter = DateFormatter()
        mformatter.dateFormat = "mm"
        let mdateString:String = Mformatter.string(from: date)
        
        //let mes = ["senderId": senderId!, "text": text!, "displayName": senderDisplayName!, "date": dateString]
        let mes = ["senderId": senderId!, "text": text!, "displayName": senderDisplayName!, "year": ydateString, "Month": MdateString, "day": ddateString, "Hour": HdateString, "minute": mdateString]
        let ref = FIRDatabase.database().reference()
        ref.child("messages").childByAutoId().setValue(mes)
    }
}
