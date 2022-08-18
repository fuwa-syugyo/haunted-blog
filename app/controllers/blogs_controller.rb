# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound if @blog.secret == true && (current_user.nil? || @blog.user != current_user)
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @blog.update(blog_params)
      render :edit, status: :unprocessable_entity
    end

    redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
  end

  def destroy
    @blog.destroy!
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    require_params = params.require(:blog)
    params_all_user = :title, :content, :secret
    if current_user.premium?
      require_params.permit(params_all_user, :random_eyecatch)
    else
      require_params.permit(params_all_user)
    end
  end
end
