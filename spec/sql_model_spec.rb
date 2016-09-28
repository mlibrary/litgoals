require 'spec_helper'
require 'minitest'
require 'minitest/spec'
require 'minitest/assertions'

require_relative "../lib/sql_DBh"

describe "Sequel Models" do


  describe "DB connection" do
    it "should be seeded" do
      DB.tables.must_include :goal
    end
  end

  describe "Person" do

    before do
      DB.tables.each { |t| DB[t].delete }
      @bill = GoalsViz::Person.new(firstname: "Bill", lastname: 'Dueber', uniqname: "dueberb")
      @bill.save
    end

    it "should create a person 'bill'" do
      assert_equal "Bill", @bill.firstname
      assert_equal "dueberb", @bill.uniqname
      assert_equal "Bill Dueber", @bill.name
    end

    it "defaults to not admin" do
      assert_equal false, !!@bill.admin?
    end

    it "can be set as admin" do
      @bill.admin!
      @bill.save
      assert @bill.admin?
    end

    it "has nil for initial parent" do
      assert_equal nil, @bill.parent
    end

    it "Can be found by uniqname" do
      b = GoalsViz::Person.find(uniqname: 'dueberb')
      assert_equal b, @bill
    end


  end

  describe "Units and People" do

    before do
      DB.tables.each { |t| DB[t].delete }
      @bill = GoalsViz::Person.new(firstname: "Bill", lastname: 'Dueber', uniqname: "dueberb")
      @bill.save

      @mike = GoalsViz::Person.new(firstname: "Mike", lastname: 'Dueber', uniqname: "dueberm")
      @mike.save

      @dla = GoalsViz::Unit.new(firstname: "DLA", uniqname: "DLA")
      @dla.save
    end

    it "starts with no people" do
      assert_equal [], @dla.people
    end

    it "assigns a unit to a person" do
      @bill.parent = @dla
      @bill.save
      b = GoalsViz::Person.find(uniqname: 'dueberb')
      assert_equal b.unit, @dla
    end

    it "does nothing (silently) if you try to add to a group with <<. You big dummy" do
      @dla.people << @bill
      @dla.save
      @bill.save

      dla2 = GoalsViz::Unit.find(uniqname: 'DLA')
      bill2 = GoalsViz::Person.find(uniqname: 'dueberb')

      assert_equal [], dla2.people
      assert_nil bill2.unit
    end

    it "allows a person to be added to a unit" do
      @dla.add_person @bill
      @dla.save

      assert_equal [@bill], @dla.people

      dla2 = GoalsViz::Unit.find(uniqname: 'DLA')
      assert_equal [@bill], dla2.people
      assert_equal dla2, @bill.unit
    end

    it "saves the person when saving just the unit it was added to" do
      @dla.add_person @mike
      @dla.save
      p = GoalsViz::Person.find(uniqname: 'dueberm')
      assert_equal p.unit, @dla
    end

    it "allows multiple people to be added to a unit" do
      @dla.add_person @bill
      @dla.add_person @mike
      @dla.save

      dla2 = GoalsViz::Unit.find(uniqname: 'DLA')
      assert_equal dla2.people.size, 2
    end


  end


  describe "Goal" do
    before do
      # Clear it out and make a few goals, people, and units
      DB.tables.each { |t| DB[t].delete }
      @g1 = GoalsViz::Goal.new(title: "Goal One")
      @g1.save

      @g2 = GoalsViz::Goal.new(title: "Goal Two")
      @g2.save

      @bill = GoalsViz::Person.new(firstname: "Bill", lastname: 'Dueber', uniqname: "dueberb")
      @bill.save

      @mike = GoalsViz::Person.new(firstname: "Mike", lastname: 'Dueber', uniqname: "dueberm")
      @mike.save

      @dla = GoalsViz::Unit.new(firstname: "DLA", uniqname: "DLA")
      @dla.save

      @dnd = GoalsViz::Unit.new(firstname: "D&D", uniqname: "D&D")
      @dnd.save
    end

    it "allows an owner" do
      @g1.add_associated_owner @dla
      @g1.save

      g1 = GoalsViz::Goal[@g1.id]
      assert_equal [@dla], g1.owners
    end

    it "allows multiple owners" do
      @g1.add_associated_owner @dla
      @g1.add_associated_owner @dnd

      @g1.save
      g1 = GoalsViz::Goal[@g1.id]
      assert_equal 2, g1.owners.size
      assert_equal [@dla, @dnd].sort{|a,b| a.uniqname <=> b.uniqname},
                   g1.owners.sort{|a,b| a.uniqname <=> b.uniqname}


    end

    it "replaces owners" do
      @g1.add_associated_owner @dla
      @g1.save

      g1 = GoalsViz::Goal[@g1.id]
      assert_equal [@dla], g1.owners
      g1.owners = [@dla, @dnd]
      g1.save

      g2 = GoalsViz::Goal[@g1.id]
      assert_equal [@dla, @dnd].sort{|a,b| a.uniqname <=> b.uniqname},
                   g2.owners.sort{|a,b| a.uniqname <=> b.uniqname}




    end





  end
end


