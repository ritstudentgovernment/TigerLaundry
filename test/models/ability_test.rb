require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  
  setup do
    @admin_ability   = Ability.new(users(:admin))
    @mod_ability     = Ability.new(users(:mod))
    @regular_ability = Ability.new(users(:regular))
  end

  ##### Test Submissions #####

  test "should allow everyone to read submissions" do
    assert_can [:admin, :mod, :regular], :read, Submission
  end

  test "should allow everyone to create submissions" do
    assert_can [:admin, :mod, :regular], :create, Submission
  end

  test "should allow only mods and admins to update submissions" do
    assert_can  [:admin, :mod], :update, Submission
    assert_cant :regular,       :update, Submission
  end

  test "should allow only certain people to destroy submissions" do
    assert_can [:admin, :mod], :destroy, Submission
    # make sure a user can delete their own submissions
    assert_can :regular, :destroy, submissions(:regular_submission)
    # make sure a user cannot delete others' submissions
    assert_cant :regular, :destroy, submissions(:anonymous_submission)
  end

  ##### Test Facilities #####
  
  test "should allow everyone to read facilities" do
    assert_can [:admin, :mod, :regular], :read, Facility
  end

  test "should allow only mods to create facilities" do
    assert_can  :admin,           :create, Facility
    assert_cant [:mod, :regular], :create, Facility
  end

  test "should allow only mods and admins to update facilities" do
    assert_can  [:mod, :admin], :update, Facility
    assert_cant :regular,       :update, Facility
  end

  test "should allow only admins to destroy facilities" do
    assert_can  :admin,           :destroy, Facility
    assert_cant [:mod, :regular], :destroy, Facility
  end

  ##### Ability Test Helpers #####

  # calls assert_can with negate set to true
  def assert_cant(user, action, model)
    assert_can(user, action, model, true)
  end

  # Helper method to assert for an ability
  # args:
  #   user:   a symbol or a list of symbols being either :admin, :mod, or :regular
  #   action: the symbol for the action to test, like :read
  #   model:  the model to test, like Facility or facilities(:ellingson)
  #   negate: optional, assert only if user _can_ do the
  #           action supplied on the model supplied
  def assert_can(user, action, model, negate=false)
    if not user.kind_of? Array
      user = [user]
    end

    user.each do |u|
      ability = @admin_ability   if u == :admin
      ability = @mod_ability     if u == :mod
      ability = @regular_ability if u == :regular

      # get the name of the class, accounting for the fact that
      # the `model` variable may be a raw class or an instantiated class
      if model.kind_of? ActiveRecord::Base
        classname = model.class.name
      else
        classname = model.name
      end

      msg = "#{u} should #{"not" if negate} be able to #{action} #{classname}"
      assert ability.can?(action, model) ^ negate, msg
    end
  end
end
