//
//  UploadVC.swift
//  PhotoWebApp
//
//  Created by Berkan Gezgin on 12.11.2021.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

            // Kullanıcı aksiyona girebilir mi?
        uploadImageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        uploadImageView.addGestureRecognizer(imageGestureRecognizer)
        
            // Klavyeyi kapatmak için ekranın herhangi bir yerine tıklanma durumu
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
            // Tıklandığında atanacak yer bildirimi
        view.addGestureRecognizer(gestureRecognizer)
    }

    @IBAction func uploadButtonclicked(_ sender: Any) {
            // Normalde db bağlantılarını yaptığımız yer burası. Ancak Firebase üzerinden erişim sağlayacağımız için burda storage değişkeni ile erişimimizi tamamlıyoruz.
        let storage = Storage.storage()
            // Firebase konumunudan referans alıyoruz.
        let storageReferance = storage.reference()
        
            // Referans ile db ulaşım sağlayarak, child ile alt klasörüne geçerek referans konumumuzu belirttik.
        let mediaFolder = storageReferance.child("images")
        
            // Görseli imageView olarak kaydedemediğimiz için veri tipini data'ya çevirip db'e öyle kaydediyoruz
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5){
                // Aldığımız data'yı images folder altına koyuyoruz ve bir isim veriyoruz.
                
            let uuid = UUID().uuidString
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            
            // let imageReferance = mediaFolder.child("image.jpg")  =>   Normalde böyle yazmıştık ancak gelen tüm görsellerin adı aynı olduğu için program önceki verinin üstüne yazıyordu ve yeni bir görsel oluşturmuyorudu. Biz de uuid vererek bu sorunu çözdük.
            
                // Veriyi indirmek için gerekli kodlar.
            imageReferance.putData(data, metadata: nil) { (storageMetaData, error ) in
                if error != nil {
                    self.errorMessage(title: "Error!", message: error?.localizedDescription ?? "Please try again..")
                } else {
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                                // imageUrl'yi stringe çevirip işlemlerimizi yönlendiriyoruz
                            let imageUrl = url?.absoluteString
                            print(imageUrl)
                        }
                    }
                }
            }
        }
    }
    
    
        // Klavyeyi kapatma fonksiyonu
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    
        // Kullanıcının galerisinden vs resim seçme
    @objc func chooseImage() {
        let  picker = UIImagePickerController()
        picker.delegate = self
            // Kullanıcı resmi kameradan mı yoksa galerinden vs mi seçecek onu belirliyoruz
        picker.sourceType = .photoLibrary
            // Kullanıcı resim seçtikten sonra düzenleme işlemlerine izin verecek miyiz?
        picker.allowsEditing = true
            // Present : Alert kontrolü gibi, sunmak anlamında.
            // Completion : Bu işlem bitince bir şey yapmak istiyor musun?
        present(picker, animated: true, completion: nil)
    }
    
    
        // Resmi seçtikten sonra ekleme ekranına seçilen resmi ekleme
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Bu fonk içerisinde bize bir dictionary veriliyor : [UIImagePickerController.InfoKey : Any]
        uploadImageView.image = info[.originalImage] as? UIImage
        // uploadButton.isEnabled = true
            // pickerController kapatmak için
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func errorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
