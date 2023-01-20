//
//  Place.swift
//  IFood
//
//  Created by Артём on 28.12.2022.
//

import RealmSwift


class Place: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double ) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    static let places = [
        Place(name: "Усадьба Грачёвка", location: "Клинская ул., 2, стр. 1", type: "Усадьбы", imageData: UIImage(named: "Усадьба Грачёвка")?.pngData(), rating: 4),
        Place(name: "Конноспортивная база ЦСКА", location: "ул. Дыбенко, 5", type: "Спортивная база", imageData: UIImage(named: "Конноспортивная база ЦСКА")?.pngData(), rating: 3),
        Place(name: "Айболит Плюс", location: "Беломорская ул., 1", type: "Ветеринарная клиника", imageData: UIImage(named: "Айболит Плюс")?.pngData(), rating: 5),
        Place(name: "Экстрим", location: "Смольная ул., 63Б", type: "Скалодром", imageData: UIImage(named: "Экстрим")?.pngData(), rating: 1),
        Place(name: "EUROSPAR", location: "Фестивальная ул., 8, корп. 1", type: "Супермаркет", imageData: UIImage(named: "EUROSPAR")?.pngData(), rating: 4),
        Place(name: "Idol Gym & Crossfit", location: "ул. Лавочкина, 23, стр. 1", type: "Фитнес-клуб", imageData: UIImage(named: "Idol Gym & Crossfit")?.pngData(), rating: 4),
        Place(name: "Каток в парке Дружбы", location: "Москва, парк Дружбы", type: "Каток", imageData: UIImage(named: "Каток в парке Дружбы")?.pngData(), rating: 5),
        Place(name: "Следственный изолятор № 3", location: "1-й Силикатный пр., 11К1", type: "Исправительное учреждение", imageData: UIImage(named: "Следственный изолятор № 3")?.pngData(), rating: 0),
        Place(name: "Музей русского импрессионизма", location: "Ленинградский просп., 15, стр. 11", type: "Музей", imageData: UIImage(named: "Музей русского импрессионизма")?.pngData(), rating: 5),
        Place(name: "Катюша", location: "ул. Кибальчича, 9", type: "Гостиница", imageData: UIImage(named: "Катюша")?.pngData(), rating: 3),
    ]
    
    
    static func saveMockPlacesInRealm() {
        StorageManager.saveObjects(places)
    }
}
