class DefectList < ActiveRecord::Base

  BUG = "Bug"

  def self.create_defect_information(projects)
    data = []
    projects.each do |project|
      project_info = {}
      project_info[:name] = project.name
      project_info[:issues] = []
      project_info[:issues_count] = 0
      project.issues.each do |issue|
        if issue.fields['issuetype']['name'] == BUG
          project_info[:issues_count] +=1
          project_info[:issues].push({
            summary: issue.summary,
            priority: issue.fields['priority']['name'],
            timespent: issue.fields['timespent'],
            assignee: (issue.fields['assignee'] || {})['emailAddress'],
            estimate: issue.fields['timeoriginalestimate']
          })
        end
      end
      data.push(project_info)
    end
    return { projects: data }
  end
end
