ActiveAdmin.register Member do
  permit_params :email, :name, :password, :password_confirmation
  actions :all, :except => [:new]

  filter :email
  filter :name
  filter :nickname
  filter :created_at
  filter :updated_at

  index do
    selectable_column

    column :name
    column :email
    column :nickname
    column :current_sign_in_at
    column :last_sign_in_at
    column :last_sign_in_ip
	  column :created_at
	  column :updated_at
    column 'Confirmed' do |member|
      if member.confirmed_at.blank?
        'Not confirmed'
      else
        'Confirmed'
      end
    end

    actions
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :name
      f.input :password
      f.input :password_confirmation
    end

    f.actions
  end

  show do |member|
    attributes_table do
      row :id
      row :email
      row :nickname
      row :sign_in_count
      row :current_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_at
      row :last_sign_in_ip
      row :created_at
      row :updated_at

      row :member_confirmed do
        if member.confirmed_at.blank?
          'Member not confirmed'
        else
          'Member confirmed'
        end
      end
    end

    active_admin_comments
  end

  action_item only: :show, if: proc { !member.confirmed? } do
    link_to 'Confirm member', confirm_admin_member_path(member), method: :put
  end

  action_item only: :show, if: proc { member.confirmed? } do
    link_to 'Unconfirm member', unconfirm_admin_member_path(member), method: :put
  end

  member_action :confirm, method: :put do
    member = Member.find(params[:id])
    member.confirm
    redirect_to [:admin, member], notice: 'member confirmed'
  end

  member_action :unconfirm, method: :put do
    member = Member.find(params[:id])
    member.unconfirm
    redirect_to [:admin, member], notice: 'member unconfirmed'
  end

end
