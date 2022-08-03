# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def edit
    if @blog.user != current_user
      raise ActiveRecord::RecordNotFound
    end
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
    if @blog.update(blog_params) && @blog.user == current_user
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      raise ActiveRecord::RecordNotFound
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog.user == current_user
      @blog.destroy!
      redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def set_blog
    if current_user.nil?
      @blog = Blog.where(secret: false).find(params[:id])
    else
      @blog = Blog.find(params[:id]).secret ? current_user.blogs.find(params[:id]) : Blog.find(params[:id])
    end
  end

  def blog_params
    if current_user.premium?
      params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
    else
      params.require(:blog).permit(:title, :content, :secret)
    end
  end
end
