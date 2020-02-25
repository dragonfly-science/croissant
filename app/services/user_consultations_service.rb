class UserConsultationsService
  def self.consultations(user)
    return Consultation.active.alphabetical_order if user.superadmin?

    user.consultations.active.alphabetical_order
  end

  def self.admin_consultations(user, consultation_order)
    return Consultation.all.order(consultation_order || "name ASC") if user.superadmin?

    consultations = user.consultations.order(consultation_order)
    consultations.select { |c| c.consultation_users.find_by(user: user, role: "admin") }
  end
end
