STAFF_FEED  = "https://alida.lib.umich.edu/library_staff.json"
DEPT_FEED   = "https://alida.lib.umich.edu/library_depts.json"
LIT_DEPT_ID = "470400"

require 'json'
require 'dry-initializer'

class Department

  NAME_MAP = {
     "Library Info Tech Dept Group" => "LIT",
     "Library Info Tech - HathiTrust" => "HathiTrust",
     "Library Info Tech - General" => "General",
     "Library Info Tech - Arch & Eng" => "A&E",
     "LibraryInfoTech - Dig. Content" => "DCC",
     "Library Info Tech - AIM" => "AIM",
     "LibraryInfoTech-Design&Discov" => "D&D",
     "Library Info Tech-Dig Lib Apps" => "DLA"
  }


  extend Dry::Initializer

  option :id
  option :name
  option :head_id
  option :head, default: -> {nil}
  option :employees, default: -> {[]}
  option :sub_departments, default: -> {[]}
  option :parent_department, default: ->{nil}

  def head
    staff_map[head_id]
  end

  def parent_department=(pd)
    @parent_department = pd
  end

  def staff_map=(sm)
    @staff_map = sm
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

  def dmap(d = self, h = {})
    return @dmap if defined? @dmap
    h[d.id] = d
    m       = h.merge d.sub_departments.reduce({}) {|h2, sd| dmap(sd, h2)}
    @dmap   = m if d == self
    m
  end

  def dept_by_id(id)
    dmap[id]
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

  def smap(s = self, h = {})
    return @smap if defined? @smap
    h[s.id] = s
    h[s.uniqname] = s
    m = h.merge s.reports.reduce({}) {|h2, r| smap(r, h2)}
    @smap = m if s == self
    m
  end

  def [](uniqname)
    smap[uniqname]
  end

end

depthash = JSON.parse(File.open(File.join(__dir__, 'library_depts.json')).read);
lit      = Department.from_json_hash(depthash['DepartmentsList'].find {|x| x['DepartmentID'] == LIT_DEPT_ID})

staffhash = JSON.parse(File.open(File.join(__dir__, 'library_staff.json')).read)
staff = StaffMember.from_json_hash(staffhash)

lit.staff_map = staff


require 'pry'; binding.pry

1
