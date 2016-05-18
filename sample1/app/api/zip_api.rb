class ZipAPI < Grape::API
  format :json

  namespace "zip/:zip_code" do
    get do
      zip = search_address
      if zip
        zip.to_json
      else
        not_found_error
      end
    end

    # basic認証
    http_basic do |username, password|
      {"user" => "pass"}[username] == password
    end
    # バリデーション
    params do
      requires :zip_code, type: String, regexp:/^\d{3}-\d{4}$/
      requires :address, type: String
    end
    put do
      add_zip
      status 204
    end

    delete do
      if remove_zip
        status 204
      else
        not_found_error
      end
    end
  end

  helpers do
    # データ取得
    def search_address
      Zip.where(zip_code: params[:zip_code]).first
    end
    # エラー時の処理
    def not_found_error
      error!("404 Not Found", 404)
    end

    # 追加処理
    def add_zip
      zip = search_address || Zip.new(zip_code: params[:zip_code])
      zip.update(address: params[:address])
    end

    # 削除処理
    def remove_zip
      zip = search_address
      zip.destroy if zip
    end

  end
end
