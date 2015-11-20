class DefectList < ActiveRecord::Base

  BUG = "Bug"

  def self.create_defect_information(projects)
    data = []
    projects.each do |project|
      project_info = {}
      project_info[:name] = project.name
      project_info[:defects] = []
      project_info[:defects_count] = 0
      project_info[:graph_data] = {}
      project_info[:graph_data][:day] = {}
      project_info[:priority_data] = {}

      # # TODO: Remove this
      # if project.name == "test_project"
      #    project_info[:graph_data][:day][Date.parse('2015-11-17')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-11-16')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-11-15')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-11-14')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-10-14')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-9-15')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-9-17')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-8-17')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-11-13')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-11-12')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-10-17')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-10-16')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-10-15')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-10-15')] = 2
      #    project_info[:graph_data][:day][Date.parse('2015-7-15')] = 2
      #    project_info[:priority_data]["Highest"] = 8
      #    project_info[:priority_data]["Medium"] = 10
      #    project_info[:priority_data]["Lowest"] = 10
      # end

      project.issues.each do |issue|
        if issue.fields['issuetype']['name'] == BUG
          project_info[:defects_count] +=1

          date = Date.parse(issue.fields['created'])
          priority = issue.fields['priority']['name']

          project_info[:graph_data][:day][date] = 0 unless project_info[:graph_data][:day][date]
          project_info[:graph_data][:day][date] += 1

          project_info[:priority_data][priority] = 0 unless project_info[:priority_data][priority]
          project_info[:priority_data][priority] += 1

          project_info[:defects].push({
            summary: issue.summary,
            priority: issue.fields['priority']['name'],
            timespent: issue.fields['timespent'],
            assignee: (issue.fields['assignee'] || {})['emailAddress'],
            estimate: issue.fields['timeoriginalestimate'],
            date: date
          })
        end
      end
      project_info[:graph_data][:day] = project_info[:graph_data][:day].sort.to_h
      data.push(project_info)
    end
    return self.aggregate_week_and_month_data(data)
  end

  def self.aggregate_week_and_month_data(data)
    data.each do |project_info|

      project_info[:graph_data][:week] = {}
      project_info[:graph_data][:month] = {}

      # TODO: Have week start on a monday
      current_week =  nil
      project_info[:graph_data][:day].each do |week, count|
        if !current_week
          current_week = week
          project_info[:graph_data][:week][current_week] = count
        elsif week <= current_week + 7
          project_info[:graph_data][:week][current_week] += count
        else
          current_week = week
          project_info[:graph_data][:week][current_week] = count
        end
      end

      current_month = nil
      project_info[:graph_data][:week].each do |date, count|
        if !current_month
          current_month = date.month
          project_info[:graph_data][:month][current_month] = count
        elsif current_month == date.month
          project_info[:graph_data][:month][current_month] += count
        else
          current_month = date.month
          project_info[:graph_data][:month][current_month] = count
        end
      end
    end
    return { projects: data }
  end
end
