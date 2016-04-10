namespace :tags do
  desc 'Create most ppular tags'
  task create_tags: :environment do
    %w(
    voucher
    hotdealvn
    buffet
    thuong thuc
    nha hang
    tai nha
    hai san
    buffet toi
    dac sac
    mon an
    hap dan
    kem
    nuong
    tiec buffet
    buffet trua
    bbq
    bo my
    huong vi
    hotel
    thu gian
    tour
    massage
    khong gian
    uu dai
    han quoc
    bua tiec
    dich vu
    cao cap
    nhat han
    sushi
    hotel voucher
    vui choi
    lau nhat
    am thuc
    thoa thich
    khach san
    hoanh trang
    viet nam
    phong cach
    mon nuong
    sang trong
    duy nhat
    dang cap
    riverside
    burger
    set
    thom ngon
    kimchi
    nuoc ngot
    tro choi
    bbq bo
    thuc don
    su kem
    banh su
    nuong lau
    spa
    cuoi tuan
    tu chon
    kem tai
    thoai mai
    bbq voucher
    am cung
    cong nghe
    tham quan
    thu vi
    banh xeo
    thit
    toan than
    bo uc
    du lich
    voi trong
    mon ngon
    buffet kem
    mien phi
    khau kich
    san khau
    tai san
    tieng
    combo
    body
    mogu
    sac trong
    gold
    khoai
    xem
    lieu trinh
    sushi nhat
    khau vi
    an viet
    nam voucher
    spa voucher
    saigon
    ren luyen
    ket hop
    flame voucher
    sai gon
    massage body
    uc nuong
    hang yaki
    yaki
    singapore
    din ky
    hang hai
    plaza hotel
    windsor plaza
    plaza
    windsor
    buffet voucher
    trang mieng
    ha noi
    buffet nuong
    ngam chan
    giai tri
    the gioi
    ky nghi
    hien dai
    da nong
    thi buffet
    kimchi kimchi
    phnom penh
    reap phnom
    siem reap
    campuchia siem
    tour campuchia
    van hoa
    gia tri
    giau gia
    den giau
    diem den
    nhung diem
    campuchia
    gym
    the chat
    mega mall
    vincom mega
    vincom
    sukiya
    riverside sai
    renaissance riverside
    san renaissance
    cafe khach
    riverside cafe
    hang riverside
    international buffet
    renaissance
    international
    yaki bao
    don buffet
    gold hotel
    kem singapore
    tuoi mat
    ngao tuoi
    ngot ngao
    kem ngot
    nhan kem
    3d artinus
    tranh 3d
    bao tang
    chup anh
    artinus
    hoa don
    rainbow yogurt
    yogurt
    rainbow
    noi tieng
    thu nhun
    ca thu
    ban ca
    ban sung
    stress
    coffee
    resort
    sukiya tai
    han voi
    moc chau
    ngoc trai
    uonduoinhuom
    hanayoshi voucher
    hang hanayoshi
    san sushi
    lau bo
    an thoa
    hanayoshi
    vien
    mrtotato
    nuoc ep
    ngot nuoc
    salad
    burger salad
    ga ran
    mon ga
    pinky spa
    massage chan
    mat na
    dap mat
    nam bo
    cach nam
    dan mang
    thit huong
    tom thit
    ).each do |tag_name|
      Tag.create(name: tag_name.strip)
    end
  end

  desc 'Create post tags'
  task create_post_tags: :environment do
    Post.all.each do |post|
      post.post_tags.where(is_auto: true).destroy_all
      post.generate_auto_post_tags
      post.save
    end
  end

  desc 'Create user tags'
  task create_user_tags: :environment do
    Post.find_each do |post|
      post.push_to_user_tags
    end
    PostLike.find_each do |post_like|
      post_like.push_to_user_tags
    end
    Comment.find_each do |comment|
      comment.push_to_user_tags
    end
  end
end