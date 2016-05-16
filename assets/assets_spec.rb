require 'spec_helper'
include Warden::Test::Helpers  

describe "Assets", js: true do
  # let(:authed_user) { create_logged_in_user }
  def insert_accessories
      Rails.logger.debug "should save accessories"
      visit new_asset_path
      page.all(".accessory_row").count
      accessory = {}
      # accessory1[""]

      click_link "Add Accessory"
      click_link "Add Accessory"
      options = ["Monitor", "Docking", "Keyboard", "Mouse", "Carrying Bag(Notebook)", "Power Cord", "Security Lock", "Others"]
      accessory_field_count = page.all(".accessory_row").count

      # first populate accessory data into variable
      accessory_field_count.times.each do |x|
        accessory[x] = {}
        accessory[x]["typ"] = options[x]
        accessory[x]["model"] = rand.to_s[2..7]
        accessory[x]["serial_number"] = rand.to_s[2..7]
      end

      all_rows = page.all(".accessory_row")
      all_rows.each_with_index do |r,i|
        r.find("option[value='#{accessory[i]["typ"]}']").select_option
        r.all("input")[0].set(accessory[i]["serial_number"]) # 
        r.all("input")[1].set(accessory[i]["model"]) # 
      end

      # accessory_field_count.times.each do |x|
      #   # puts "#{x} #{accessory[x]["typ"]} #asset_accessories_attributes_#{x}_typ option[value='#{accessory[x]["typ"]}']"
      #   # find("#asset_accessories_attributes_#{x}_typ").find("option[value='#{accessory[x]["typ"]}']").click
      #   select "#{accessory[x]["typ"]}", :from => "asset_accessories_attributes_#{x}_typ"
      #   fill_in "asset_accessories_attributes_#{x}_model", with: accessory[x]["model"]
      #   fill_in "asset_accessories_attributes_#{x}_serial_number", with: accessory[x]["serial_number"]
      # end
      user = FactoryGirl.build(:customer)
      fill_in "User Name", with: user.name
      fill_in "User Department", with: user.department
      fill_in "User Position", with: user.position
      fill_in "User Email", with: user.email
      fill_in "User Company", with: user.company

      @asset = FactoryGirl.build(:asset)
      fill_in "Model", with: @asset.model
      fill_in "Asset ID", with: @asset.id
      fill_in "PO Number", with: @asset.po_number
      fill_in "asset_principle", with: @asset.principle

  end
  before(:each) do
    $user = FactoryGirl.build(:user)
    # login_as(user)
    # login_as(user, :scope => :user)
    $user = User.create password: $user.password, email: $user.email
    visit new_user_session_path
    fill_in "Email", with: $user.email
    fill_in "Password", with: $user.password
    click_button "Log in"
  end


  it "validates customer email" do
    visit new_asset_path
    fill_in "User Email", with: "asd@asdf"
    click_button("Save")
    page.should have_content("User email is invalid")
  end

  it "displays add accessories button" do
    visit new_asset_path
    page.should have_link("Add Accessory", href: "#")
  end

  # test if we can delete accessories
  it "remove accessories form from dom if id is empty (unsaved assets)" do
      insert_accessories
      # click_button("Save")
      # asset = Asset.first
      # visit edit_asset_path(asset)
      accessories = page.all(".accessory_row")
      # puts "Accessory count is #{accessories.count}"
      accessories.each do |a|
        a.find(:css, ".remove_accessory").click
      end
      # accesso_count = page.execute_script %{ $(".accessory_row").length }
      # puts "accesso_count #{accesso_count}"
      accessories = page.all(".accessory_row")
      expect(accessories.count).to eq(0)
  end

  it "remove form's accessories for saved assets" do
      insert_accessories
      click_button("Save")
      asset = Asset.first
      expect(asset.accessories.count).to eq(2)
      visit edit_asset_path(asset)
      accessories = page.all(".accessory_row")
      accessories.each do |a|
        a.find(:css, ".remove_accessory").click
      end
      accessories = page.all(".accessory_row")
      expect(accessories.count).to eq(0) # accesories were hidden
      # find(:css, ".accessory_row").should_not be_visible
      click_button("Save")
      # puts "Accessory count is #{accessories.count}"
      expect(asset.accessories.count).to eq(0)
  end


  it "should show accessory field on add" do
    visit new_asset_path
    # page.should have_no_selector(:css, '#asset_accessories_attributes_0_typ') 
    # find(:css, ".accessory_row").should_not be_visible
    expect(page).not_to have_selector(:css, ".accessory_row")
    click_link "Add Accessory"
    accessory_field_count = page.all(".accessory_row").count
    expect(page).to have_selector(:css, ".accessory_row")
    # page.find(:css, ".accessory_row").should be_visible
    # expect(accessory_field_count).to eq(1)
    # page.should have_selector(:css, '#asset_accessories_attributes_0_typ') 
    # click_link "Add Accessory"
    accessory_field_count = page.all(".accessory_row").count
    # expect(accessory_field_count).to eq(2)
    # puts "oo #{page.all(".accessory_row").count}"
  end

  # test if we can add accessories
  it "should save asset and its accessories" do
    insert_accessories
    click_button("Save")
    last_asset = Asset.last
    Rails.logger.debug "find last asset #{last_asset.id}"
    last_asset_po = last_asset.po_number
    expect(last_asset_po).to eq(@asset.po_number)
  end

  # test if we can modify accessory
  it "hide accessory and set _destroy to true" do

    expect(page).to have_selector('#blah', visible: true)
    fail

  end

  it "add accessory form dom" do
    fail
  end

  it "collected item should not be do anything" do
  end
end

# NOTESSS
# 
# find('#my_element')['class']
# => "highlighted clearfix some_other_css_class"

# find('a#my_element')['href']
# => "http://example.com

# or in general, find any attribute, even if it does not exist
# find('a#my_element')['no_such_attribute']
# => ""
# 
# titles = page.all("ul.bars li a div.description p.title")

# Make sure that the first and second have the correct content
# titles[0].should have_content("a")
# titles[1].should have_content("b")
