FactoryGirl.define do
  factory :asset_usage do
    customer_id 1
    asset_id 1
    collect_by 1
    created_by 1
    collect_remark "MyString"
  end
end
