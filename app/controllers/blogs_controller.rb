# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit
    @blog = current_user.blogs.find(params[:id])
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @blog.update(blog_params) && @blog.user == current_user
      render :edit, status: :unprocessable_entity
      raise ActiveRecord::RecordNotFound
    end

    redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
  end

  def destroy
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user

    @blog.destroy!
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])

    raise ActiveRecord::RecordNotFound if @blog.secret == true && (current_user.nil? || @blog.user != current_user)
  end

  def blog_params
    params_all_user = :title, :content, :secret
    if current_user.premium?
      params.require(:blog).permit(params_all_user, :random_eyecatch)
    else
      params.require(:blog).permit(params_all_user)
    end
  end
end
