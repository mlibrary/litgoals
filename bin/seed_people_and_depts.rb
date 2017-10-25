require_relative '../lib/db'


STAFF_FEED = "https://alida.lib.umich.edu/library_staff.json"
DEPT_FEED  = "https://alida.lib.umich.edu/library_depts.json"

require 'json'
require 'dry-initializer'

class Department

  NAME_MAP = {
    "Library Info Tech Dept Group"   => "LIT",
    "Library Info Tech - HathiTrust" => "HathiTrust",
    "Library Info Tech - General"    => "General",
    "Library Info Tech - Arch & Eng" => "A&E",
    "LibraryInfoTech - Dig. Content" => "DCC",
    "Library Info Tech - AIM"        => "AIM",
    "LibraryInfoTech-Design&Discov"  => "D&D",
    "Library Info Tech-Dig Lib Apps" => "DLA"
  }


  extend Dry::Initializer

  option :id
  option :name
  option :head_id
  option :head, default: -> {nil}
  option :employees, default: -> {[]}
  option :sub_departments, default: -> {[]}
  option :parent_department, default: -> {nil}

  def initialize(*args, **kwargs)
    super
  end

  def head
    staff_map[head_id]
  end

  def parent_department=(pd)
    @parent_department = pd
  end

  def staff_map=(sm)
    @staff_map = sm
    @staff_map.values.uniq.each {|s| s.department = dept_by_id(s.department_id)}
  end

  def staff_map
    return @staff_map if @staff_map
    parent_department ? parent_department.staff_map : nil
  end


  def staff_member(x)
    staff_map ? staff_map[x] : nil
  end

  alias_method :[], :staff_member

  def self.from_json_hash(dh)
    d = Department.new(id:      dh['DepartmentID'],
                       name:    NAME_MAP[dh['DepartmentName']],
                       head_id: dh['DepartmentHeadID']
    )
    dh['DepartmentsList'].map {|x| from_json_hash(x)}.each do |sd|
      d.sub_departments << sd
      sd.parent_department = d
    end
    d
  end

  def dmap
    @dmap ||= self.create_dmap
  end

  def create_dmap(d = self, h = {})
    h[d.id] = d
    h.merge d.sub_departments.reduce({}) {|h2, sd| create_dmap(sd, h2)}
  end

  def dept_by_id(id)
    dmap[id]
  end

  def dept_by_head_uniqname(u)
    dmap.values.find {|x| x.head && x.head.uniqname == u}
  end

  def is_within(target)
    id == target.id or (!parent_department.nil? and parent_department.is_within(target))
  end


  def staff
    @staff ||= staff_map.values.select {|x| x.department && x.department.is_within(self)}.uniq
  end

  def departments
    dmap.values
  end

end


class StaffMember
  extend Dry::Initializer

  option :id
  option :department_id
  option :uniqname
  option :first_name
  option :last_name
  option :title
  option :display_name
  option :manager
  option :reports, default: -> {[]}
  option :department, default: -> {nil}
  option :manager, default: -> {nil}

  attr_reader :department
  alias_method :name, :display_name

  def self.from_json_hash(rawstaff, manager = nil)
    s = self.new(id:            rawstaff['EmployeeID'],
                 department_id: rawstaff['DepartmentID'],
                 uniqname:      rawstaff['Uniqname'],
                 first_name:    rawstaff['First Name'],
                 last_name:     rawstaff['Last Name'],
                 title:         rawstaff['Title'],
                 display_name:  rawstaff['DisplayName'],
                 manager:       manager,
    )
    s.reports.concat(rawstaff["DirectReports"].map {|dr| from_json_hash(dr, s)})
    s
  end

  def manager=(s)
    @manager = s
  end

  def department=(d)
    @department = d
  end


  def smap(s = self, h = {})
    return @smap if defined? @smap
    h[s.id]       = s
    h[s.uniqname] = s
    m             = h.merge s.reports.reduce({}) {|h2, r| smap(r, h2)}
    @smap         = m if s == self
    m
  end

  def [](uniqname)
    smap[uniqname]
  end


end

depthash = JSON.parse(File.open(File.join(__dir__, 'library_depts.json')).read);
library = Department.from_json_hash(depthash)

staffhash = JSON.parse(File.open(File.join(__dir__, 'library_staff.json')).read)
staff     = StaffMember.from_json_hash(staffhash)

library.staff_map = staff.smap

lit = library.sub_departments.find {|x| x.head.uniqname == 'mcyork'}

# OK. We've got all the departments and people
# Let's stick them in there
#
#


STATUS = [
  'Not started',
  'On hold',
  'In progress',
  'Completed',
  'Abandoned'
]

PLATFORM = {
  create: 'Create',
  scale:  'Scale',
  build:  'Build'
}

def seed_statuses
  db = GoalsViz.new_db_connection
  db[:status].delete
  STATUS.map do |status|
    db[:status].insert(name: status)
  end
end

def update_people_and_departments(lit)
  db = GoalsViz.new_db_connection
  db[:goalowner].delete
  lit.departments.each do |d|
    db[:goalowner].insert(
      id:              d.id.to_i,
      uniqname:        d.name,
      lastname:        d.name,
      parent_uniqname: d.parent_department.name,
      is_unit:         true
    )
  end


  lit.staff.each do |s|
    puts "#{s.uniqname} of #{s.department.name}"
    db[:goalowner].insert(
      id:              s.id.to_i,
      uniqname:        s.uniqname,
      lastname:        s.last_name,
      firstname:       s.first_name,
      parent_uniqname: s.department.name,
      is_unit:         false,
      is_admin:        !(lit.dept_by_head_uniqname(s.uniqname).nil?)
    )
  end
end

seed_statuses
update_people_and_departments(lit)
