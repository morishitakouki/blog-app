# サンプルのユーザーと記事（タイムラインの見た目確認用）。何度実行しても重複しない。

users = [
  { email: "haru@example.com",  username: "haru",   display_name: "春野 はる",
    bio: "活版印刷とコーヒーが好き。日々のことを綴っています。" },
  { email: "ren@example.com",   username: "ren_ink", display_name: "蓮",
    bio: "エンジニア。技術と暮らしのメモ帳。" },
  { email: "mio@example.com",   username: "mio",    display_name: "澪",
    bio: "本と旅と万年筆。" },
]

records = users.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password = "password"
    u.username = attrs[:username]
    u.display_name = attrs[:display_name]
    u.bio = attrs[:bio]
  end
end

articles = [
  { user: records[0], title: "はじめての一篇",
    body: "綴り、はじめました。\n\n小さな気づきや読んだ本のこと、これから少しずつ書き留めていきます。続けることを目標に、肩の力を抜いて。" },
  { user: records[1], title: "Rails で“いいね”を実装した話",
    body: "Turbo Streams を使うと、ページ全体を再読み込みせずにボタンの状態だけを差し替えられる。\n\n部分テンプレートを1つ用意して、それを replace するだけ。とても気持ちがいい。" },
  { user: records[2], title: "雨の日の喫茶店で",
    body: "窓ガラスを伝う雨を眺めながら、ぬるくなった珈琲を飲む。\n\nこういう何でもない時間が、いちばん豊かなのかもしれない。" },
  { user: records[0], title: "万年筆のインクを変えた",
    body: "ブルーブラックから、少し緑がかった青へ。\n\n字を書くのが楽しくなる小さな変化。道具を整えると、続けたくなる。" },
]

articles.each do |attrs|
  attrs[:user].articles.find_or_create_by!(title: attrs[:title]) do |a|
    a.body = attrs[:body]
  end
end

# 適当にいいねを付ける
Article.find_each do |article|
  records.sample(rand(1..3)).each do |u|
    u.likes.find_or_create_by!(article: article)
  end
end

puts "Seeded #{User.count} users, #{Article.count} articles, #{Like.count} likes."
