//
//  NetworkManager.swift
//  FetchMeals
//
//  Created by Han Kim on 3/24/22.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
}

struct Meal: Decodable {
    let name: String
    let thumbnailURL: URL?
    let id: Int

    enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case thumbnailURLString = "strMealThumb"
        case id = "idMeal"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let rawThumbnailURLString = try container.decode(String.self, forKey: .thumbnailURLString)
        thumbnailURL = URL(string: rawThumbnailURLString)

        let idString = try container.decode(String.self, forKey: .id)
        id = Int(idString) ?? 0
    }
}
struct RootMeal: Decodable {

    enum RootCodingKeys: String, CodingKey {
        case meals
    }

    let meals: [Meal]

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        meals = try rootContainer.decode([Meal].self, forKey: .meals)
    }
}

struct MealDetail: Decodable {

}

class NetworkManager {

    func fetchDesserts() async -> [Meal] {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            return []
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
            let meals = try JSONDecoder().decode(RootMeal.self, from: data).meals
            return meals
        } catch {
            return []
        }
    }

    func fetchMealDetails(forMealId id: String) async throws -> [MealDetail] {

        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            return []
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
            let mealDetails = try JSONDecoder().decode([MealDetail].self, from: data)
            return mealDetails
        } catch {
            return []
        }
    }
}
