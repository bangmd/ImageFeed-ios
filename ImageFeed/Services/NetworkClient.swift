import Foundation

class NetworkClient{
    private let urlSession = URLSession.shared
    
    enum NetworkError: Error {
        case codeError
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case decodingError(Error)
        case invalidRequest
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        handler: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let session = urlSession.dataTask(with: request) { data, response, error in
            if let error = error{
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.codeError))
                }
                return
            }
            
            guard let data = data else { return }
            do {
                let responseBody = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    handler(.success(responseBody))
                }
            }catch let  dataError{
                DispatchQueue.main.async {
                    handler(.failure(dataError))
                }
            }
        }
        return session
    }
    
    
}
