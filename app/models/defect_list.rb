class DefectList < ActiveRecord::Base

  BUG = "Bug"

  def self.create_defect_information(projects)
    data = {}
    projects.each_with_index do |project, idx|
      data[idx] = {}
      data[idx][:name] = project.name
      data[idx][:issues] = []
      data[idx][:issues_count] = 0
      project.issues.each do |issue|
        if issue.fields['issuetype']['name'] == BUG
          data[idx][:issues_count] +=1
          data[idx][:issues].push({
            summary: issue.summary,
            priority: issue.fields['priority']['name'],
            timespent: issue.fields['timespent'],
            assignee: (issue.fields['assignee'] || {})['emailAddress'],
            estimate: issue.fields['timeoriginalestimate']
          })
        end
      end
    end
    return { projects: [data] }
  end
  
end
