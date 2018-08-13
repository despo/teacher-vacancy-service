['Chemistry', 'Economics', 'General Science',
'History', 'Maths', 'Other',
'Primary', 'Spanish', 'Art',
'Classics', 'English Language', 'Geography',
'ICT', 'Media Studies', 'Physical Education',
'Psychology', 'Statistics', 'Biology',
'Design Technology', 'English Literature', 'German',
'Latin', 'Music', 'Physics',
'Religious Studies', 'Business Studies', 'Drama',
'French', 'Health and Social care', 'Law',
'Politics', 'Sociology'].each do |subject|
  Subject.create(name: subject)
end

raise if Rails.env.production?

require 'faker'
require 'factory_bot_rails'

Rake::Task['data:local_authorities:import'].invoke

payscales = [['MPS1', 'Minimum Pay Range 1', 22917], ['MPS2', 'Minimum Pay Range 2', 24728],
             ['MPS3', 'Minimum Pay Range 3', 26716], ['MPS4', 'Minimum Pay Range 4', 28772],
             ['MPS5', 'Minimum Pay Range 5', 31029], ['MPS6', 'Minimum Pay Range 6', 33824],
             ['UPS1', 'Upper Pay Range 1', 35927], ['UPS2', 'Upper Pay Range 2', 37258],
             ['UPS3', 'Upper Pay Range 3', 38633], ['LPS1', 'Lead Practitioners Range 1', 39374],
             ['LPS2', 'Lead Practitioners Range 2', 40360], ['LPS3', 'Lead Practitioners Range 3', 41368],
             ['LPS4', 'Lead Practitioners Range 4', 42398], ['LPS5', 'Lead Practitioners Range 5', 43454],
             ['LPS6', 'Lead Practitioners Range 6', 44544], ['LPS7', 'Lead Practitioners Range 7', 45743],
             ['LPS8', 'Lead Practitioners Range 8', 46799], ['LPS9', 'Lead Practitioners Range 9', 47967],
             ['LPS10', 'Lead Practitioners Range 10', 49199], ['LPS11', 'Lead Practitioners Range 11', 50476],
             ['LPS12', 'Lead Practitioners Range 12', 51639], ['LPS13', 'Lead Practitioners Range 13', 52930],
             ['LPS14', 'Lead Practitioners Range 14', 54250], ['LPS15', 'Lead Practitioners Range 15', 55600],
             ['LPS16', 'Lead Practitioners Range 16', 57077], ['LPS17', 'Lead Practitioners Range 17', 58389],
             ['LPS18', 'Lead Practitioners Range 18', 59857], ['LPS19', 'Lead Practitioners Range 19', 61341],
             ['LPS20', 'Lead Practitioners Range 20', 62863], ['LPS21', 'Lead Practitioners Range 21', 64417],
             ['LPS22', 'Lead Practitioners Range 22', 66017], ['LPS23', 'Lead Practitioners Range 23', 67652],
             ['LPS24', 'Lead Practitioners Range 24', 69330], ['LPS25', 'Lead Practitioners Range 25', 71053],
             ['LPS26', 'Lead Practitioners Range 26', 72810], ['LPS27', 'Lead Practitioners Range 27', 74615],
             ['LPS28', 'Lead Practitioners Range 28', 76466], ['LPS29', 'Lead Practitioners Range 29', 78359],
             ['LPS30', 'Lead Practitioners Range 30', 80310], ['LPS31', 'Lead Practitioners Range 31', 82293],
             ['LPS32', 'Lead Practitioners Range 32', 84339], ['LPS33', 'Lead Practitioners Range 33', 86435],
             ['LPS34', 'Lead Practitioners Range 34', 88571], ['LPS35', 'Lead Practitioners Range 35', 90773],
             ['LPS36', 'Lead Practitioners Range 36', 93020], ['LPS37', 'Lead Practitioners Range 37', 95333],
             ['LPS38', 'Lead Practitioners Range 38', 97692], ['LPS39', 'Lead Practitioners Range 39', 100072],
             ['LPS40', 'Lead Practitioners Range 40', 102570], ['LPS41', 'Lead Practitioners Range 41', 105132],
             ['LPS42', 'Lead Practitioners Range 42', 107766], ['LPS43', 'Lead Practitioners Range 43', 109366]].freeze

roc_region = RegionalPayBandArea.find_by(name: 'Rest of England')
payscales.each_with_index do |scale, index|
  PayScale.new(code: scale[0],
               index: index,
               label: scale[1],
               salary: scale[2],
               regional_pay_band_area: roc_region,
               starts_at: Date.new(2017, 9, 1),
               expires_at: Date.new(2018, 8, 31))
end

Rake::Task['data:seed:pay_scale'].invoke

middlesborough_la = LocalAuthority.find_by(name: 'Middlesbrough')
york_la = LocalAuthority.find_by(name: 'York')

london = Region.create(name: 'London', code: 'H')
Region.create(name: 'South East England', code: 'J')
Region.create(name: 'South West England', code: 'K')
Region.create(name: 'Yorkshire and the Humber', code: 'D')
Region.create(name: 'North West England', code: 'B')
Region.create(name: 'West Midlands', code: 'F')
Region.create(name: 'East Midlands', code: 'E')
Region.create(name: 'North East England', code: 'A')

academy = SchoolType.create(label: 'Academy', code: '10')
SchoolType.create(label: 'Independent School', code: '3')
SchoolType.create(label: 'Free School', code: '11')
SchoolType.create(label: 'LA Maintained School', code: '4')
SchoolType.create(label: 'Special School', code: '5')


ealing_school = FactoryBot.create(:school, name: 'Macmillan Academy ',
                                  school_type: academy,
                                  urn: 137138,
                                  address: 'Stockton Road',
                                  phase: :secondary,
                                  town: 'Middlesbrough',
                                  postcode: 'TS5 4AG',
                                  url: 'http://www.macmillan-academy.org.uk',
                                  regional_pay_band_area: roc_region,
                                  local_authority: middlesborough_la,
                                  geolocation: '(54.565770,-1.264489)')

bromley_school = FactoryBot.create(:school,
                                   name: ' Sacred Heart Roman Catholic VA School - A Specialist Science College',
                                   school_type: academy,
                                   urn: 110628,
                                   address: 'Mersey Road',
                                   phase: :secondary,
                                   town: 'Redcar',
                                   county: 'North Yorkshire',
                                   postcode: 'TS10 1PJ',
                                   local_authority: york_la,
                                   region: london,
                                   regional_pay_band_area: roc_region,
                                   geolocation: '(54.612422,-1.079842)')

payscale = PayScale.limit(5).sample(1).first
leadership = Leadership.limit(1).sample(1).first

FactoryBot.create(:vacancy,
                  job_title: 'Physics Teacher',
                  subject: Subject.first,
                  school: ealing_school,
                  minimum_salary: 40000,
                  maximum_salary: 45000,
                  min_pay_scale: payscale,
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'Maths Teacher',
                  subject: Subject.last,
                  school: bromley_school,
                  working_pattern: :part_time,
                  minimum_salary: 30000,
                  maximum_salary: 35000,
                  min_pay_scale: payscale,
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'PE Teacher',
                  subject: Subject.last,
                  school: ealing_school,
                  working_pattern: :part_time,
                  minimum_salary: 30000,
                  maximum_salary: 35000,
                  min_pay_scale: payscale,
                  leadership: leadership)

FactoryBot.create(:vacancy,
                  job_title: 'Geography Teacher',
                  subject: Subject.last,
                  school: ealing_school,
                  working_pattern: :part_time,
                  minimum_salary: 30000,
                  maximum_salary: 35000,
                  min_pay_scale: payscale,
                  status: 1,
                  leadership: leadership)
