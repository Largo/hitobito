class Event::QualificationsController < ApplicationController
    
  before_filter :authorize

  decorates :event, :leaders, :participants, :participation, :group
  
  helper_method :event, :participation
  
  def index
    entries
  end
  
  def update
    qualifier.issue
    @failed = !qualifier.qualified?
    render 'qualification'
  end
  
  def destroy
    qualifier.revoke
    render 'qualification'
  end
  
  private
   
  def entries
    @leaders ||= participations(*Event::Qualifier.leader_types(event))
    @participants ||= participations(event.class.participant_type)
  end
  
  def qualifier
    Event::Qualifier.for(participation)
  end
  
  def event
    @event ||= group.events.find(params[:event_id])
  end
    
  def group
    @group ||= Group.find(params[:group_id])
  end
  
  def participation
    @participation ||= event.participations.find(params[:id])
  end
  
  def participations(*role_types)
    event.participations_for(*role_types).includes(:event)
  end
  
  def authorize
    authorize!(:qualify, event)
  end
end
